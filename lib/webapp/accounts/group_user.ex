defmodule Webapp.Accounts.GroupUser do
  use Ecto.Schema
  import Ecto.Changeset

  alias Webapp.{
    Types.UserRole,
    Accounts.User,
    Accounts.Group,
    Types.UserRole
    }

  schema "groups_users" do
    belongs_to(:user, User)
    belongs_to(:group, Group)
    field(:role, UserRole, default: "User")
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:role, :user_id])
    |> validate_required([:role, :user_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:group)
  end

end
