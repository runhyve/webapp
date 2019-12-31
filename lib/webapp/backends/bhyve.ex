defmodule Webapp.Hypervisors.Bhyve do
  @moduledoc """
  The Bhyve hypervisor.
  """
  require Logger
  alias Webapp.Repo

  alias Webapp.{
    Hypervisors,
    Hypervisors.Hypervisor,
    Machines,
    Machines.Machine,
    Networks.Network,
    Distributions,
    Accounts
  }

  @headers [{"Content-Type", "application/json"}]

  @doc """
  Get details about hypervisor's operating system
  """
  def hypervisor_os_details(hypervisor), do: webhook_trigger(hypervisor, "vm/ohai")

  @doc """
  Checks hypervisor status.
  """
  def hypervisor_status(hypervisor), do: webhook_trigger(hypervisor, "vm/health")

  @doc """
  Creates a machine on bhyve hypervisor.
  """
  def create_machine(_repo, _multi_changes, %Machine{} = machine) do
    machine = Repo.preload(machine, [:plan, :hypervisor, :networks, ipv4: [:ip_pool]])


    #  Before we can call create_machine webhook we need to
    #  make sure there is:
    #   - template for selected system and plan
    #   - image

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

    case webhook_trigger(machine.hypervisor, "vm/create", payload) do
      {:ok, %{"taskid" => task_id}} -> {:ok, task_id}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Deletes a machine on bhyve hypervisor.
  """
  def delete_machine(_repo, _multi_changes, %Machine{} = machine) do
    payload = %{name: Machines.get_machine_hid(machine)}

    case webhook_trigger(machine.hypervisor, "vm/destroy", payload) do
      {:ok, %{"taskid" => task_id}} -> {:ok, task_id}

      {:error, error} ->
        if String.match?(error, ~r/Virtual machine (.*) doesn't exist/) do
          # Machine does not exists on the hypervisor, it's safe to remove it form the database.
          {:ok, error}
        else
          {:error, error}
        end
    end
  end

  @doc """
  Updates a machine status.
  """
  def update_machine_status(_repo, _multi_changes, %Machine{} = machine) do
    payload = %{name: Machines.get_machine_hid(machine)}

    case webhook_trigger(machine.hypervisor, "vm/status", payload) do
      {:ok, %{"state" => status}} -> {:ok, status}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Adds a network to machine.
  """
  def add_network_to_machine(_repo, %{machine: %Machine{} = machine}) do
    # Since we are adding network to machine, last one is the new one.
    [network] = tl(machine.networks)
    payload = %{machine: Machines.get_machine_hid(machine), network: network.name}
    webhook_trigger(machine.hypervisor, "vm/add-network", payload)
  end

  @doc """
  Starts a machine.
  """
  def start_machine(%{machine: %Machine{} = machine}) do
    payload = %{name: Machines.get_machine_hid(machine)}
    webhook_trigger(machine.hypervisor, "vm/start", payload)
  end

  @doc """
  Stops a machine.
  """
  def stop_machine(%{machine: %Machine{} = machine}) do
    payload = %{name: Machines.get_machine_hid(machine)}
    webhook_trigger(machine.hypervisor, "vm/stop", payload)
  end

  @doc """
  Performs hard stop of virtual Machine.
  """
  def poweroff_machine(%{machine: %Machine{}  = machine}) do
    payload = %{name: Machines.get_machine_hid(machine)}
    webhook_trigger(machine.hypervisor, "vm/poweroff", payload)
  end

  @doc """
  Opens a remote console for machine.
  """
  def console_machine(%{machine:  %Machine{} = machine}) do
    payload = %{name: Machines.get_machine_hid(machine)}
    webhook_trigger(machine.hypervisor, "vm/console", payload)
  end

  @doc """
  Checks a job status.
  """
  def job_status(_repo, _multi_changes, %Hypervisor{} = hypervisor, task_id) do
    payload = %{taskid: task_id}
    webhook_trigger(hypervisor, "vm/ts-get-task", payload)
  end

  @doc """
  Creates a network.
  """
  def create_network(_repo, _multi_changes, %Network{} = network) do
    payload = %{
      name: network.name,
      cidr: "#{network.network}"
    }
    webhook_trigger(network.hypervisor, "/vm/net-create", payload)
  end

  defp webhook_trigger(%Hypervisor{} = hypervisor, endpoint) do
    endpoint = Hypervisors.get_hypervisor_url(hypervisor, :webhook) <> endpoint

    Logger.debug(["Bhyve webhook GET call: #{inspect(endpoint)} without parameters"])

    HTTPoison.get(endpoint, @headers ++ [{"X-RUNHYVE-TOKEN", hypervisor.webhook_token}], follow_redirect: true)
    |> process_response()
  end

  defp webhook_trigger(%Hypervisor{} = hypervisor, endpoint, payload) do
    endpoint = Hypervisors.get_hypervisor_url(hypervisor, :webhook) <> endpoint

    try do
      json = Jason.encode!(payload)
      Logger.debug(["Bhyve webhook POST call: #{inspect(endpoint)} with #{inspect(json)}"])

      HTTPoison.post(endpoint, json, @headers ++ [{"X-RUNHYVE-TOKEN", hypervisor.webhook_token}],
        follow_redirect: true,
        hackney: [force_redirect: true]
      )
      |> process_response()
    rescue
      e -> {:error, e.message}
    end
  end

  defp process_response({:ok, %{body: body, status_code: 200}}) do
    Logger.debug(["Bhyve webhook response: #{inspect(body)}"])
    webhook_process_response(body)
  end

  defp process_response({:ok, %{body: body, status_code: 404}}) do
    Logger.debug(["Bhyve webhook response with code 404"])
    {:error, body}
  end

  defp process_response({:ok, %{body: body, status_code: 403}}) do
    Logger.debug(["Bhyve webhook response with code 403"])
    {:error, body}
  end

  defp process_response({:ok, %{body: body, status_code: _}}) do
    Logger.debug(["Bhyve webhook response #{inspect(body)}"])
    webhook_process_response(body)
  end

  defp process_response({:error, %HTTPoison.Error{reason: reason}}) do
    Logger.debug(["HTTPoison Error: #{inspect(reason)}"])
    {:error, reason}
  end

  defp webhook_process_response(json) do
    case Jason.decode(json) do
      {:ok, %{"status" => "success", "message" => message}} -> {:ok, message}
      {:ok, %{"status" => "error", "message" => message}} -> {:error, message}
      {:ok, %{"status" => "success"} = response} -> {:ok, response}
      {:ok, _} -> {:error, "Invalid response"}
      {:error, %Jason.DecodeError{data: _error}} -> {:error, "Invalid response"}
      {:error, error} -> {:error, error}
    end
  end
end
