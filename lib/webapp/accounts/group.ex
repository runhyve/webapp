defmodule Webapp.Accounts.Group do
  use Ecto.Schema
  import Ecto.Changeset

  alias Webapp.{
    Types.UserRole,
    Accounts.User,
    Accounts.Namespace
  }

  schema "groups" do
    field(:name, :string)

    belongs_to(:namespace, Namespace)
    many_to_many(:users, User, join_through: "groups_users")

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name,])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end

  @doc false
  def create_changeset(group, attrs) do
    group
    |> cast(attrs, [:name,])
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> cast_assoc(:namespace, with: &Namespace.group_changeset/2, required: true)
    |> assoc_constraint(:namespace)
  end

  @doc false
  def update_changeset(group, attrs), do: create_changeset(group, attrs)

end
