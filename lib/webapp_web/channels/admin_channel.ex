defmodule WebappWeb.AdminChannel do
  use WebappWeb, :channel

  alias Webapp.{
    Machines,
    Machines.Machine,
    Accounts
  }

  import WebappWeb.MachineView, only: [map_status_to_css: 1, status_icon: 1]

  def join("machines:" <> machines, payload, socket) do
    if authorized?(payload) do
      socket = assign(socket, :machines, machines)
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


  def handle_in("status", payload, socket) do
    machines = String.split(socket.assigns[:machines], ",")
      |> Enum.map(fn id ->
        machine = Machines.get_machine!(id)
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

    broadcast(socket, "status", response)
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
