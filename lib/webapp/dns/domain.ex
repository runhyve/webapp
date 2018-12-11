defmodule Webapp.DNS.Domain do
  use Ecto.Schema
  import Ecto.Changeset

  schema "domains" do
    field(:name, :string)
    field(:master, :string)
    field(:type, :string)
    field(:notified_serial, :integer)
    field(:userid, :integer)

    has_many(:records, Webapp.DNS.Record)
  end

  @doc false
  def changeset(type, attrs) do
    type
    |> cast(attrs, [:name, :type, :userid])
    |> validate_required([:name, :type, :userid])
  end
end
