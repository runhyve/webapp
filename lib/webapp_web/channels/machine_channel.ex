defmodule WebappWeb.MachineChannel do
  use WebappWeb, :channel

  alias Webapp.{
    Machines,
    Machines.Machine,
    Accounts
  }

  import WebappWeb.MachineView, only: [map_status_to_css: 1, status_icon: 1]

  def join("machine:" <> machine_id, payload, socket) do
    if authorized?(payload) do
      socket = assign(socket, :machine_id, machine_id)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def join("team:" <> team_id, payload, socket) do
    if authorized?(payload) do
      team = Accounts.get_team!(team_id)

      socket = assign(socket, :team, team)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("status", _payload, socket) do
    machine =
      socket.assigns[:machine_id]
      |> Machines.get_machine!()

    response = %{
      id: machine.id,
      success: true,
      status_css: map_status_to_css(machine.last_status),
      icon: status_icon(machine.last_status),
      status: machine.last_status,
      actions: machine_actions(machine)
    }

    broadcast(socket, "status", response)
    {:noreply, socket}
  end

  def handle_in("status_team", _payload, socket) do
    machines =
      Machines.list_team_machines(socket.assigns[:team], [:hypervisor, :plan, :networks])
      |> Enum.map(fn machine ->
        %{
          id: machine.id,
          status_css: map_status_to_css(machine.last_status),
          icon: status_icon(machine.last_status),
          status: machine.last_status,
          actions: machine_actions(machine)
        }
      end)

    response = %{
      success: true,
      machines: machines
    }

    broadcast(socket, "status_team", response)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  defp machine_actions(%Machine{} = machine) do
    %{
      start: Machines.machine_can_do?(machine, :start),
      stop: Machines.machine_can_do?(machine, :stop),
      console: Machines.machine_can_do?(machine, :console),
      poweroff: Machines.machine_can_do?(machine, :poweroff)
    }
  end
end
