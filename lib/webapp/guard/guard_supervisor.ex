defmodule Webapp.GuardSupervisor do
  use Supervisor

  alias Webapp.Guard.{MachineGuard, HypervisorGuard}

  @doc """
  Starts the process supervisor.
  """
  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      MachineGuard,
      HypervisorGuard
    ]

    if Mix.env() != :test do
      {:ok, _} = Logger.add_backend(Sentry.LoggerBackend)
      Logger.configure_backend(Sentry.LoggerBackend, include_logger_metadata: true)
    end

    Supervisor.init(children, strategy: :one_for_one)
  end
end
