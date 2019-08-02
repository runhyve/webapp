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

    Supervisor.init(children, strategy: :one_for_one)
  end
end
