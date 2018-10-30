defmodule WebappWeb.HypervisorChannel do
  use WebappWeb, :channel

  alias Webapp.{
    Hypervisors
  }

  import WebappWeb.HypervisorView, only: [map_status_to_css: 1, status_icon: 1]

  def join("hypervisor:" <> hypervisor_id, payload, socket) do
    if authorized?(payload) do
      socket = assign(socket, :hypervisor_id, hypervisor_id)
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
    hypervisor =
      socket.assigns[:hypervisor_id]
      |> Hypervisors.get_hypervisor!()

    Hypervisors.update_hypervisor_status(hypervisor)

    status =
      case Hypervisors.update_hypervisor_status(hypervisor) do
        {:ok, status} -> status
        {:error, _} -> "unreachable"
      end

    payload = %{status_css: map_status_to_css(status), icon: status_icon(status), status: status}

    broadcast(socket, "status", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
