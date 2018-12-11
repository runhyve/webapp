defmodule Webapp.DNS.Record do
  use Ecto.Schema
  import Ecto.Changeset

  schema "records" do
    field(:name, :string)
    field(:type, :string)
    field(:content, :string)
    field(:prio, :integer)
    field(:ttl, :integer)
    field(:userid, :integer)

    belongs_to(:domain, Webapp.DNS.Domain)
  end

  @doc false
  def changeset(type, attrs) do
    type
    |> cast(attrs, [:name, :type, :userid])
    |> validate_required([:name, :type, :userid])
  end
end
