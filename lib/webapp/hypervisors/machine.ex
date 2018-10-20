defmodule Webapp.Hypervisors.Machine do
  use Ecto.Schema
  import Ecto.Changeset


  schema "machines" do
    field :name, :string
    field :template, :string

    belongs_to :hypervisor, Webapp.Hypervisors.Hypervisor
    belongs_to :plan, Webapp.Plans.Plan

    timestamps()
  end

  @doc false
  def changeset(machine, attrs) do
    machine
    |> cast(attrs, [:name, :template, :hypervisor_id, :plan_id])
    |> validate_required([:name, :template, :hypervisor_id, :plan_id])
    |> foreign_key_constraint(:hypervisor_id)
    |> foreign_key_constraint(:plan_id)
  end
end
