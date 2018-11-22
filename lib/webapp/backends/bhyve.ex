defmodule Webapp.Hypervisors.Bhyve do
  @moduledoc """
  The Bhyve hypervisor.
  """
  require Logger
  alias Webapp.Repo

  alias Webapp.{
    Machines.Machine,
    Networks.Network
  }

  @headers [{"Content-Type", "application/json"}]

  @doc """
  Checks hypervisor status.
  """
  def hypervisor_status(hypervisor) do
    endpoint = hypervisor.webhook_endpoint <> "/vm/health"
    token = hypervisor.webhook_token

    try do
      case webhook_trigger(token,endpoint) do
        {:ok, status} -> {:ok, status}
        {:error, error} -> {:error, error}
      end
    rescue
      e -> {:error, e.message}
    end
  end

  @doc """
  Creates a machine on bhyve hypervisor.
  """
  def create_machine(_repo, _multi_changes, %Machine{} = machine) do
    machine = Repo.preload(machine, [:plan, :hypervisor, :networks])

    """
      Before we can call create_machine webhook we need to
      make sure there is:
       - template for selected system and plan
       - image
    """

    # TODO: add the template model with system and image field.
    system = machine.template

    image =
      case machine.template do
        "freebsd" ->
          "FreeBSD-11.2-RELEASE-amd64.raw"

        "ubuntu" ->
          "xenial-server-cloudimg-amd64-uefi1.img"
      end

    [network | _] = machine.networks

    # TODO: machine name should be prefixed with owner namespace.
    payload = %{
      "plan" => machine.plan.name,
      "name" => machine.name,
      "system" => system,
      "image" => image,
      "network" => network.name
    }

    endpoint = machine.hypervisor.webhook_endpoint <> "/vm/create"
    token = machine.hypervisor.webhook_token

    try do
      case webhook_trigger(token,endpoint, payload) do
        {:ok, %{"taskid" => task_id}} -> {:ok, task_id}
        {:error, error} -> {:error, error}
      end
    rescue
      e -> {:error, e.message}
    end
  end

  @doc """
  Deletes a machine on bhyve hypervisor.
  """
  def delete_machine(_repo, %{machine: machine}) do
    endpoint = machine.hypervisor.webhook_endpoint <> "/vm/destroy"
    token = machine.hypervisor.webhook_token
    payload = %{name: machine.name}

    try do
      case webhook_trigger(token,endpoint, payload) do
        {:ok, message} -> {:ok, message}
        {:error, error} -> {:error, error}
      end
    rescue
      e -> {:error, e.message}
    end
  end

  @doc """
  Updates a machine status.
  """
  def update_machine_status(_repo, %{machine: machine}) do
    endpoint = machine.hypervisor.webhook_endpoint <> "/vm/status"
    token = machine.hypervisor.webhook_token
    payload = %{name: machine.name}

    try do
      # TODO: Map statuses to unified format.
      case webhook_trigger(token,endpoint, payload) do
        {:ok, %{"state" => status}} -> {:ok, status}
        {:error, error} -> {:error, error}
      end
    rescue
      e -> {:error, e.message}
    end
  end

  @doc """
  Adds a network to machine.
  """
  def add_network_to_machine(_repo, %{machine: machine}) do
    # Since we are adding network to machine, last one is the new one.
    [network] = tl(machine.networks)

    endpoint = machine.hypervisor.webhook_endpoint <> "/vm/add-network"
    token = machine.hypervisor.webhook_token
    payload = %{machine: machine.name, network: network.name}

    try do
      webhook_trigger(token,endpoint, payload)
    rescue
      e -> {:error, e.message}
    end
  end

  @doc """
  Starts a machine.
  """
  def start_machine(%{machine: machine}) do
    endpoint = machine.hypervisor.webhook_endpoint <> "/vm/start"
    token = machine.hypervisor.webhook_token
    payload = %{name: machine.name}

    try do
      webhook_trigger(token,endpoint, payload)
    rescue
      e -> {:error, e.message}
    end
  end

  @doc """
  Stops a machine.
  """
  def stop_machine(%{machine: machine}) do
    endpoint = machine.hypervisor.webhook_endpoint <> "/vm/stop"
    token = machine.hypervisor.webhook_token
    payload = %{name: machine.name}

    try do
      webhook_trigger(token,endpoint, payload)
    rescue
      e -> {:error, e.message}
    end
  end

  @doc """
  Performs hard stop of virtual Machine.
  """
  def poweroff_machine(%{machine: machine}) do
    endpoint = machine.hypervisor.webhook_endpoint <> "/vm/poweroff"
    token = machine.hypervisor.webhook_token
    payload = %{name: machine.name}

    try do
      webhook_trigger(token,endpoint, payload)
    rescue
      e -> {:error, e.message}
    end
  end

  @doc """
  Opens a remote console for machine.
  """
  def console_machine(%{machine: machine}) do
    endpoint = machine.hypervisor.webhook_endpoint <> "/vm/console"
    token = machine.hypervisor.webhook_token
    payload = %{name: machine.name}

    try do
      webhook_trigger(token,endpoint, payload)
    rescue
      e -> {:error, e.message}
    end
  end

  @doc """
  Checks a job status.
  """
  def job_status(hypervisor, task_id) do
    endpoint = hypervisor.webhook_endpoint <> "/vm/ts-get-task"
    token = hypervisor.webhook_token
    payload = %{taskid: task_id}

    try do
      webhook_trigger(token,endpoint, payload)
    rescue
      e -> {:error, e.message}
    end
  end

  @doc """
  Creates a network.
  """
  def create_network(_repo, _multi_changes, %Network{} = network) do
    network = Repo.preload(network, [:hypervisor])

    endpoint = network.hypervisor.webhook_endpoint <> "/vm/net-create"
    token = network.hypervisor.webhook_token

    payload = %{
      name: network.name,
      cidr: "#{network.network}"
    }

    try do
      webhook_trigger(token,endpoint, payload)
    rescue
      e -> {:error, e.message}
    end
  end

  defp webhook_trigger(token,endpoint) do
    Logger.debug("Bhyve webhook GET call: #{endpoint} without parameters")

    case HTTPoison.get(endpoint, @headers ++ [{"X-RUNHYVE-TOKEN", token}], follow_redirect: true) do
      {:ok, %{body: body, status_code: 200}} ->
        Logger.debug("Bhyve webhook response: #{body}")
        webhook_process_response(body)

      {:ok, %{body: body, status_code: _}} ->
        Logger.debug("Bhyve webhook response: #{body}")
        webhook_process_response(body)

      {:error, error} ->
        {:error, "HTTPoison Error: " <> HTTPoison.Error.message(error)}
    end
  end

  defp webhook_trigger(token,endpoint, payload) do
    json = Jason.encode!(payload)
    Logger.debug("Bhyve webhook POST call: #{endpoint} with #{json}")

    case HTTPoison.post(endpoint, json, @headers ++ [{"X-RUNHYVE-TOKEN", token}], follow_redirect: true, hackney: [force_redirect: true]) do
      {:ok, %{body: body, status_code: 200}} ->
        Logger.debug("Bhyve webhook response: #{body}")
        webhook_process_response(body)

      {:ok, %{body: body, status_code: _}} ->
        Logger.debug("Bhyve webhook response: #{body}")
        webhook_process_response(body)

      {:error, error} ->
        {:error, "HTTPoison Error: " <> HTTPoison.Error.message(error)}
    end
  end

  defp webhook_process_response(json) do
    case Jason.decode(json) do
      {:ok, %{"status" => "success", "message" => message}} -> {:ok, message}
      {:ok, %{"status" => "error", "message" => message}} -> {:error, message}
      {:ok, %{"status" => "success"} = response} -> {:ok, response}
      {:ok, _} -> {:error, "Invalid response"}
      {:error, %Jason.DecodeError{data: error}} -> {:error, error}
      {:error, error} -> {:error, error}
    end
  end
end
