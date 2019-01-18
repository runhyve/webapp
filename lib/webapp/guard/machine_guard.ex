defmodule Webapp.Guard.MachineGuard do
  use GenServer

  alias Webapp.Machines

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(state) do
    schedule()
    {:ok, state}
  end

  def handle_info(:check_status, state) do
    check_status()
    {:noreply, state}
  end

  def schedule do
    Process.send_after(self(), :check_status, 5000)
  end

  def check_status() do
    for machine <- Machines.list_machines() do
      Machines.update_status(machine)
    end

    schedule()
  end
end
