defmodule Webapp.Machines.Machine do
  use Ecto.Schema
  import Ecto.Changeset

  alias Webapp.{
    Hypervisors,
    Hypervisors.Hypervisor,
    Networks,
    Networks.Network
  }

  alias Webapp.Plans.Plan

  schema "machines" do
    field(:name, :string)
    field(:template, :string)
    field(:last_status, :string)
    field(:created, :boolean, default: false)
    field(:job_id, :integer)

    belongs_to(:hypervisor, Hypervisor)
    belongs_to(:plan, Plan)
    many_to_many(:networks, Network, join_through: "machines_networks")

    timestamps()
  end

  @doc false
  def changeset(machine, attrs) do
    network_ids = Map.get(attrs, "network_ids", [])
    networks = Networks.list_networks_by_id(network_ids)

    machine
    |> cast(attrs, [:name, :template, :hypervisor_id, :plan_id])
    |> validate_required([:name, :template, :hypervisor_id, :plan_id])
    |> unique_constraint(:name)
    |> assoc_constraint(:hypervisor)
    |> assoc_constraint(:plan)
    |> put_assoc(:networks, networks)
    |> validate_length(:networks, min: 1)
  end

  def networks_changeset(machine, networks) do
    machine
    |> cast(%{}, [])
    |> put_assoc(:networks, networks)
    |> validate_length(:networks, min: 1)
  end

  def update_changeset(machine, attrs) do
    machine
    |> cast(attrs, [:last_status, :job_id])
  end
end
