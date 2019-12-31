defmodule Webapp.Distributions.Distribution do
  use Ecto.Schema
  import Ecto.Changeset

  schema "distributions" do
    field(:image, :string)
    field(:loader, :string)
    field(:name, :string)
    field(:version, :string)
    field(:archived_at, :utc_datetime, default: nil)

    has_many(:machines, Webapp.Machines.Machine)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(distribution, attrs) do
    distribution
    |> cast(attrs, [:name, :version, :image, :loader, :archived_at])
    |> validate_required([:name, :version, :image, :loader])
  end
end
