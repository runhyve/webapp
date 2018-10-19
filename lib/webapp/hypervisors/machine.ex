defmodule Webapp.Hypervisors.Machine do
  use Ecto.Schema
  import Ecto.Changeset


  schema "machines" do
    field :name, :string
    field :template, :string

    belongs_to :hypervisor, Webapp.Hypervisors.Hypervisor

    timestamps()
  end

  @doc false
  def changeset(machine, attrs) do
    machine
    |> cast(attrs, [:name, :template, :hypervisor_id])
    |> validate_required([:name, :template, :hypervisor_id])
    |> foreign_key_constraint(:hypervisor_id)
  end
end
