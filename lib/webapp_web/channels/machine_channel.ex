defmodule WebappWeb.MachineChannel do
  use WebappWeb, :channel

  alias Webapp.{
    Hypervisors,
    Hypervisors.Machine
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

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("status", payload, socket) do
    machine =
      socket.assigns[:machine_id]
      |> Hypervisors.get_machine!()

    response =
      case Hypervisors.check_machine_status(machine) do
        {:ok, %Machine{} = machine} ->
          %{
            status_css: map_status_to_css(machine.last_status),
            icon: status_icon(machine.last_status),
            status: machine.last_status
          }

        {:error, message} ->
          %{success: false, error: message}
      end

    actions = %{
      start: Hypervisors.machine_can_do?(machine, :start),
      stop: Hypervisors.machine_can_do?(machine, :stop),
      console: Hypervisors.machine_can_do?(machine, :console),
      poweroff: Hypervisors.machine_can_do?(machine, :poweroff)
    }

    broadcast(socket, "status", Map.put(response, :actions, actions))
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
