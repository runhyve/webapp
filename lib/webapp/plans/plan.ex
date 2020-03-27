defmodule Webapp.Plans.Plan do
  use Ecto.Schema
  import Ecto.Changeset


  schema "plans" do
    field(:name, :string)
    field(:cpu, :integer)
    field(:ram, :integer)
    field(:storage, :integer)
    field(:price, :integer)
    field(:currency_code, :string)
    field(:period, :integer, default: 1)
    field(:period_unit, :string) #

    has_many(:machines, Webapp.Machines.Machine)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(plan, attrs) do
    plan
    |> cast(attrs, [:name, :storage, :ram, :cpu, :price, :currency_code, :period_unit])
    |> validate_required([:name, :storage, :ram, :cpu, :price, :currency_code, :period_unit])
    |> unique_constraint(:name)
  end
end
