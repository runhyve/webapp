defmodule Webapp.Hypervisors.Machine do
  use Ecto.Schema
  import Ecto.Changeset

  schema "machines" do
    field(:name, :string)
    field(:template, :string)
    field(:last_status, :string)
    field(:created, :boolean, default: false)

    belongs_to(:hypervisor, Webapp.Hypervisors.Hypervisor)
    belongs_to(:plan, Webapp.Plans.Plan)

    timestamps()
  end

  @doc false
  def changeset(machine, attrs) do
    machine
    |> cast(attrs, [:name, :template, :hypervisor_id, :plan_id])
    |> validate_required([:name, :template, :hypervisor_id, :plan_id])
    |> unique_constraint(:name)
    |> assoc_constraint(:hypervisor)
    |> assoc_constraint(:plan)
  end
end
