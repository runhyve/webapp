defmodule Webapp.Hypervisors.Bhyve do
  @moduledoc """
  The Bhyve hypervisor.
  """
  require Logger
  alias Webapp.Repo

  @headers [{"Content-Type", "application/json"}]

  @doc """
  Checks hypervisor status.
  """
  def hypervisor_status(hypervisor) do
    endpoint = hypervisor.webhook_endpoint <> "/vm/health"

    try do
      case webbook_trigger(endpoint) do
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
  def create_machine(%{machine: machine}) do
    machine = Repo.preload(machine, [:plan, :hypervisor])

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

    # TODO: Prepare network for the machine.
    # TODO: machine name should be prefixed with owner namespace.
    payload = %{
      "plan" => machine.plan.name,
      "name" => machine.name,
      "system" => system,
      "image" => image,
      "network" => "public"
    }

    endpoint = machine.hypervisor.webhook_endpoint <> "/vm/create"

    try do
      case webbook_trigger(endpoint, payload) do
        {:ok, message} -> {:ok, message}
        {:error, error} -> {:error, error}
      end
    rescue
      e -> {:error, e.message}
    end
  end

  @doc """
  Deletes a machine on bhyve hypervisor.
  """
  def delete_machine(%{machine: machine}) do
    endpoint = machine.hypervisor.webhook_endpoint <> "/vm/destroy"
    payload = %{name: machine.name}

    try do
      case webbook_trigger(endpoint, payload) do
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
  def update_machine_status(%{machine: machine}) do
    endpoint = machine.hypervisor.webhook_endpoint <> "/vm/status"
    payload = %{name: machine.name}

    try do
      # TODO: Map statuses to unified format.
      case webbook_trigger(endpoint, payload) do
        {:ok, %{"state" => status}} -> {:ok, status}
        {:error, error} -> {:error, error}
      end
    rescue
      e -> {:error, e.message}
    end
  end

  @doc """
  Starts a machine.
  """
  def start_machine(%{machine: machine}) do
    endpoint = machine.hypervisor.webhook_endpoint <> "/vm/start"
    payload = %{name: machine.name}

    try do
      webbook_trigger(endpoint, payload)
    rescue
      e -> {:error, e.message}
    end
  end

  @doc """
  Stops a machine.
  """
  def stop_machine(%{machine: machine}) do
    endpoint = machine.hypervisor.webhook_endpoint <> "/vm/stop"
    payload = %{name: machine.name}

    try do
      webbook_trigger(endpoint, payload)
    rescue
      e -> {:error, e.message}
    end
  end

  @doc """
  Opens a remote console for machine.
  """
  def console_machine(%{machine: machine}) do
    endpoint = machine.hypervisor.webhook_endpoint <> "/vm/console"
    payload = %{name: machine.name}

    try do
      webbook_trigger(endpoint, payload)
    rescue
      e -> {:error, e.message}
    end
  end

  defp webbook_trigger(endpoint) do
    Logger.debug("Bhyve webhook GET call: #{endpoint} without parameters")

    case HTTPoison.get(endpoint, @headers) do
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

  defp webbook_trigger(endpoint, payload) do
    json = Poison.encode!(payload)
    Logger.debug("Bhyve webhook POST call: #{endpoint} with #{json}")

    case HTTPoison.post(endpoint, json, @headers) do
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
    case Poison.decode(json) do
      {:ok, %{"status" => "success", "message" => message}} -> {:ok, message}
      {:ok, %{"status" => "error", "message" => message}} -> {:error, message}
      {:ok, %{"status" => "success"} = response} -> {:ok, response}
      {:ok, _} -> {:error, "Invalid response"}
      {:error, error} -> {:error, error}
    end
  end
end
