defmodule Webapp.NotificationsSupervisor do
  use Supervisor
  require Logger

  @doc """
  Starts the process supervisor.
  """
  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = Application.get_env(:webapp, Webapp.Notifications)[:enabled_modules]

    Logger.info("Initializing Notifications Supervisor. Enabled modules: #{Enum.join(children, ", ")}")
    Supervisor.init(children, strategy: :one_for_one)
  end
end
