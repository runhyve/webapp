defmodule Webapp.Hypervisors.Bhyve do
  @moduledoc """
  The Bhyve hypervisor.
  """
  require Logger
  alias Webapp.Repo

  @headers [{"Content-Type", "application/json"}]

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
        {:ok, %{"status" => "success", "message" => message}} -> {:ok, message}
        {:ok, %{"status" => "error", "message" => error}} -> {:ok, error}
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
        {:ok, %{"status" => "success", "message" => message}} -> {:ok, message}
        {:ok, %{"status" => "error", "message" => error}} -> {:ok, error}
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
        {:ok, %{"status" => "success", "message" => %{"state" => status}}} -> {:ok, status}
        {:ok, %{"status" => "error", "message" => error}} -> {:error, error}
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
      case webbook_trigger(endpoint, payload) do
        {:ok, %{"status" => "success", "message" => message}} -> {:ok, message}
        {:ok, %{"status" => "error", "message" => error}} -> {:ok, error}
        {:error, error} -> {:error, error}
      end
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
      case webbook_trigger(endpoint, payload) do
        {:ok, %{"status" => "success", "message" => message}} -> {:ok, message}
        {:ok, %{"status" => "error", "message" => error}} -> {:ok, error}
        {:error, error} -> {:error, error}
      end
    rescue
      e -> {:error, e.message}
    end
  end

  @doc """
  Performs hard stop of virtual Machine.
  """
  def poweroff_machine(%{machine: machine}) do
    endpoint = machine.hypervisor.webhook_endpoint <> "/vm/poweroff"
    payload = %{name: machine.name}

    try do
      case webbook_trigger(endpoint, payload) do
        {:ok, %{"status" => "success", "message" => message}} -> {:ok, message}
        {:ok, %{"status" => "error", "message" => error}} -> {:ok, error}
        {:error, error} -> {:error, error}
      end
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

  defp webbook_trigger(endpoint, payload) do
    json = Poison.encode!(payload)
    Logger.debug "Bhyve webhook call: #{endpoint} with #{json}"

    case HTTPoison.post(endpoint, json, @headers) do
      {:ok, %{body: body, status_code: 200}} ->
        case Poison.decode(body) do
          {:ok, body} -> {:ok, body}
          {:error, error} -> {:error, error}
        end

      {:ok, %{body: body, status_code: _}} ->
        case Poison.decode(body) do
          {:ok, body} -> {:ok, body}
          {:error, _error} -> {:error, body}
        end

      {:error, error} ->
        {:error, "HTTPoison Error: " <> HTTPoison.Error.message(error)}
    end
  end
end
