defmodule Webapp.Accounts.Group do
  use Ecto.Schema
  import Ecto.Changeset

  alias Webapp.{
    Types.UserRole,
    Accounts.User
  }

  schema "groups" do
    field(:name, :string)
    field(:namespace, :string)
    many_to_many(:users, User, join_through: "groups_users")

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :namespace])
    |> validate_required([:name, :namespace])
    |> unique_constraint(:name)
    |> validate_format(:namespace, ~r/^[a-zA-Z0-9_-]+$/,
      message: "Namespace must only contain letters and numbers and _ -"
    )
    |> unique_constraint(:namespace)
  end
end
