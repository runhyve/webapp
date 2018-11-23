defmodule Webapp.Accounts.Member do
  use Ecto.Schema
  import Ecto.Changeset

  alias Webapp.{
    Types.UserRole,
    Accounts.User,
    Accounts.Team,
    Types.UserRole
  }

  schema "members" do
    belongs_to(:user, User)
    belongs_to(:team, Team)
    field(:role, UserRole, default: "User")

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:role, :user_id,])
    |> validate_required([:role, :user_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:team)
  end

  @doc false
  def create_changeset(team, attrs) do
    team
    |> cast(attrs, [:role, :user_id, :team_id])
    |> validate_required([:role, :user_id, :team_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:team)
  end
end
