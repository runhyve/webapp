defmodule Webapp.Accounts.Group do
  use Ecto.Schema
  import Ecto.Changeset

  alias Webapp.{
    Accounts.User,
    Accounts.GroupUser,
    Accounts.Namespace
  }

  schema "groups" do
    field(:name, :string)

    belongs_to(:namespace, Namespace)
    has_many(:members, GroupUser, on_delete: :delete_all)

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end

  @doc false
  def create_changeset(group, attrs) do
    group
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> cast_assoc(:namespace, with: &Namespace.group_changeset/2, required: true)
    |> assoc_constraint(:namespace)
    |> cast_assoc(:members, required: true)
  end

  @doc false
  def update_changeset(group, attrs), do: create_changeset(group, attrs)

end
