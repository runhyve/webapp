defmodule Webapp.Guard.JobGuard do
  use GenServer

  alias Webapp.Jobs

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
    Process.send_after(self(), :check_status, 1000)
  end

  def check_status() do
    for job <- Jobs.list_active_jobs() do
      Jobs.update_status(job)
    end

    schedule()
  end
end
