defmodule Webapp.TestHelpers do
  alias Webapp.{Hypervisors, Plans, Machines, Networks.Network }
  alias Webapp.Repo

  def fixture_hypervisor(hypervisor) do
    {:ok, %{hypervisor: hypervisor}} = Hypervisors.create_hypervisor(hypervisor)
    hypervisor
  end

  def fixture_hypervisor_type(hypervisor_type) do
    {:ok, hypervisor_type} = Hypervisors.create_type(hypervisor_type)
    hypervisor_type
  end

  def fixture_plan(plan) do
    {:ok, plan} = Plans.create_plan(plan)
    plan
  end

  def fixture_machine(machine) do
    {:ok, %{machine: machine}} = Machines.create_machine(machine)
    machine
  end

  def fixture_network(network) do
    {:ok, network} = %Network{}
                                 |> Network.changeset(network)
                                 |> Repo.insert()
    network
  end
end
