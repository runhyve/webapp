defmodule Webapp.Regions.Region do
  use Ecto.Schema
  import Ecto.Changeset

  alias Webapp.Hypervisors.Hypervisor

  schema "regions" do
    field :name, :string
    has_many(:hypervisors, Hypervisor)

    timestamps()
  end

  @doc false
  def changeset(region, attrs) do
    region
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 64)
    |> unique_constraint(:name)
  end
end
