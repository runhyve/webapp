defmodule Webapp.Plans.Plan do
  use Ecto.Schema
  import Ecto.Changeset

  schema "plans" do
    field(:cpu, :integer)
    field(:name, :string)
    field(:ram, :integer)
    field(:storage, :integer)

    has_many(:machines, Webapp.Machines.Machine)

    timestamps()
  end

  @doc false
  def changeset(plan, attrs) do
    plan
    |> cast(attrs, [:name, :storage, :ram, :cpu])
    |> validate_required([:name, :storage, :ram, :cpu])
    |> unique_constraint(:name)
  end
end
