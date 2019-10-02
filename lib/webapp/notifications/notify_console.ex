defmodule Webapp.Notifications.NotifyConsole do
  use GenServer
  require Logger
  alias Phoenix.Socket.Broadcast

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    WebappWeb.Endpoint.subscribe("machines")
    {:ok, %{}}
  end

  def handle_call(:get, _, state) do
    {:reply, state, state}
  end

  def handle_info(%Broadcast{topic: _, event: event, payload: payload}, socket) do
    Logger.info("[NotifyConsole] #{payload.severity}: #{payload.msg}")

    {:noreply, []}
  end
end