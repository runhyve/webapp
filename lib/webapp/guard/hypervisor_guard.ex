defmodule Webapp.Guard.HypervisorGuard do
  use GenServer

  alias Webapp.Hypervisors

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(state) do
    schedule()
    {:ok, state}
  end

  def handle_info(:update_status, state) do
    update_status()
    {:noreply, state}
  end

  def schedule do
    Process.send_after(self(), :update_status, 5000)
  end

  def update_status() do
    for hypervisor <- Hypervisors.list_hypervisors() do
      # This function calls hypervisor only when data in cache exceeded its TTL
      # TTL value is set in ConCache's configuration in application.ex 
      Hypervisors.update_hypervisor_os_details(hypervisor)
    end

    schedule()
  end

end