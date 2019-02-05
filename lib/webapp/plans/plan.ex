defmodule Webapp.Plans.Plan do
  use Ecto.Schema
  import Ecto.Changeset

  schema "plans" do
    field(:cpu, :integer)
    field(:name, :string)
    field(:ram, :integer)
    field(:storage, :integer)
    field(:price, :integer)

    has_many(:machines, Webapp.Machines.Machine)

    timestamps()
  end

  @doc false
  def changeset(plan, attrs) do
    plan
    |> cast(attrs, [:name, :storage, :ram, :cpu, :price])
    |> validate_required([:name, :storage, :ram, :cpu, :price])
    |> unique_constraint(:name)
  end
end
