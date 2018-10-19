defmodule Webapp.Hypervisors.Type do
  use Ecto.Schema
  import Ecto.Changeset


  schema "hypervisor_types" do
    field :name, :string

    has_many :hypervisors, Webapp.Hypervisors.Hypervisor

    timestamps()
  end

  @doc false
  def changeset(type, attrs) do
    type
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
