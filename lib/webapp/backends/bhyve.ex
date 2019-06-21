defmodule Webapp.Hypervisors.Bhyve do
  @moduledoc """
  The Bhyve hypervisor.
  """
  require Logger
  alias Webapp.Repo

  alias Webapp.{
    Hypervisors,
    Machines,
    Machines.Machine,
    Networks.Network,
    Distributions,
    Accounts
  }

  @headers [{"Content-Type", "application/json"}]

  @doc """
  Checks hypervisor status.
  """
  def hypervisor_status(hypervisor) do
    endpoint = Hypervisors.get_hypervisor_url(hypervisor, :webhook) <> "/vm/health"
    token = hypervisor.webhook_token

    try do
      case webhook_trigger(token, endpoint) do
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
    machine = Repo.preload(machine, [:plan, :hypervisor, :networks, ipv4: [:ip_pool]])

    """
      Before we can call create_machine webhook we need to
      make sure there is:
       - template for selected system and plan
       - image
    """

    distribution = Distributions.get_distribution!(machine.distribution_id)

    image = Distributions.get_img_name(distribution)
    template = distribution.loader

    [network | _] = machine.networks

    payload = %{
      "name" => Machines.get_machine_hid(machine),
      "template" => template,
      "image" => image,
      # TODO: replace to network.uuid
      "network" => network.name,
      "cpu" => machine.plan.cpu,
      "memory" => "#{machine.plan.ram}M",
      "disk" => "#{machine.plan.storage}G",
      "ipv4" => Enum.map(machine.ipv4, fn ip ->
        %{
          ip: to_string(ip.ip),
          netmask: to_string(ip.ip_pool.netmask),
          gateway: to_string(ip.ip_pool.gateway)
        } |> Jason.encode!()
      end)
    }

    payload =
      if machine.ssh_public_key_id != nil do
        ssh_public_key = Accounts.get_ssh_public_key!(machine.ssh_public_key_id)
        Map.put(payload, "ssh_public_key", ssh_public_key.ssh_public_key)
      else
        payload
      end

    endpoint = Hypervisors.get_hypervisor_url(machine.hypervisor, :webhook) <> "/vm/create"
    token = machine.hypervisor.webhook_token

    try do
      case webhook_trigger(token, endpoint, payload) do
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
    endpoint = Hypervisors.get_hypervisor_url(machine.hypervisor, :webhook) <> "/vm/destroy"
    token = machine.hypervisor.webhook_token
    payload = %{name: Machines.get_machine_hid(machine)}

    try do
      case webhook_trigger(token, endpoint, payload) do
        {:ok, message} ->
          {:ok, message}

        {:error, error} ->
          if String.match?(error, ~r/Virtual machine (.*) doesn't exist/) do
            {:ok, error}
          else
            {:error, error}
          end
      end
    rescue
      e -> {:error, e.message}
    end
  end

  @doc """
  Updates a machine status.
  """
  def update_machine_status(_repo, %{machine: machine}) do
    endpoint = Hypervisors.get_hypervisor_url(machine.hypervisor, :webhook) <> "/vm/status"
    token = machine.hypervisor.webhook_token
    payload = %{name: Machines.get_machine_hid(machine)}

    try do
      # TODO: Map statuses to unified format.
      case webhook_trigger(token, endpoint, payload) do
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

    endpoint = Hypervisors.get_hypervisor_url(machine.hypervisor, :webhook) <> "/vm/add-network"
    token = machine.hypervisor.webhook_token
    payload = %{machine: Machines.get_machine_hid(machine), network: network.name}

    try do
      webhook_trigger(token, endpoint, payload)
    rescue
      e -> {:error, e.message}
    end
  end

  @doc """
  Starts a machine.
  """
  def start_machine(%{machine: machine}) do
    endpoint = Hypervisors.get_hypervisor_url(machine.hypervisor, :webhook) <> "/vm/start"
    token = machine.hypervisor.webhook_token
    payload = %{name: Machines.get_machine_hid(machine)}

    try do
      webhook_trigger(token, endpoint, payload)
    rescue
      e -> {:error, e.message}
    end
  end

  @doc """
  Stops a machine.
  """
  def stop_machine(%{machine: machine}) do
    endpoint = Hypervisors.get_hypervisor_url(machine.hypervisor, :webhook) <> "/vm/stop"
    token = machine.hypervisor.webhook_token
    payload = %{name: Machines.get_machine_hid(machine)}

    try do
      webhook_trigger(token, endpoint, payload)
    rescue
      e -> {:error, e.message}
    end
  end

  @doc """
  Performs hard stop of virtual Machine.
  """
  def poweroff_machine(%{machine: machine}) do
    endpoint = Hypervisors.get_hypervisor_url(machine.hypervisor, :webhook) <> "/vm/poweroff"
    token = machine.hypervisor.webhook_token
    payload = %{name: Machines.get_machine_hid(machine)}

    try do
      webhook_trigger(token, endpoint, payload)
    rescue
      e -> {:error, e.message}
    end
  end

  @doc """
  Opens a remote console for machine.
  """
  def console_machine(%{machine: machine}) do
    endpoint = Hypervisors.get_hypervisor_url(machine.hypervisor, :webhook) <> "/vm/console"
    token = machine.hypervisor.webhook_token
    payload = %{name: Machines.get_machine_hid(machine)}

    try do
      webhook_trigger(token, endpoint, payload)
    rescue
      e -> {:error, e.message}
    end
  end

  @doc """
  Checks a job status.
  """
  def job_status(hypervisor, task_id) do
    endpoint = Hypervisors.get_hypervisor_url(hypervisor, :webhook) <> "/vm/ts-get-task"
    token = hypervisor.webhook_token
    payload = %{taskid: task_id}

    try do
      webhook_trigger(token, endpoint, payload)
    rescue
      e -> {:error, e.message}
    end
  end

  @doc """
  Creates a network.
  """
  def create_network(_repo, _multi_changes, %Network{} = network) do
    network = Repo.preload(network, [:hypervisor])

    endpoint = Hypervisors.get_hypervisor_url(network.hypervisor, :webhook) <> "/vm/net-create"
    token = network.hypervisor.webhook_token

    payload = %{
      name: network.name,
      cidr: "#{network.network}"
    }

    try do
      webhook_trigger(token, endpoint, payload)
    rescue
      e -> {:error, e.message}
    end
  end

  defp webhook_trigger(token, endpoint) do
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

  defp webhook_trigger(token, endpoint, payload) do
    json = Jason.encode!(payload)
    Logger.debug("Bhyve webhook POST call: #{endpoint} with #{json}")

    case HTTPoison.post(endpoint, json, @headers ++ [{"X-RUNHYVE-TOKEN", token}],
           follow_redirect: true,
           hackney: [force_redirect: true]
         ) do
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
