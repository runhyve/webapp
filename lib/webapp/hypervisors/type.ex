defmodule Webapp.Hypervisors.Type do
  use Ecto.Schema
  import Ecto.Changeset

  schema "hypervisor_types" do
    field(:name, :string)

    timestamps()
  end

  @doc false
  def changeset(type, attrs) do
    type
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
