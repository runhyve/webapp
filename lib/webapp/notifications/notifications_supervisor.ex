defmodule Webapp.NotificationsSupervisor do
  use Supervisor

  alias Webapp.Notifications.{
    NotifyConsole,
    NotifySlack
  }

  @doc """
  Starts the process supervisor.
  """
  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = Application.get_env(:webapp, Webapp.Notifications)[:enabled_modules]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
