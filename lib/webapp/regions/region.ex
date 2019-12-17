defmodule Webapp.Regions.Region do
  use Ecto.Schema
  import Ecto.Changeset

  schema "regions" do
    field :name, :string

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
