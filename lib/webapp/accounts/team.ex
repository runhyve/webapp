defmodule Webapp.Accounts.Team do
  use Ecto.Schema
  import Ecto.Changeset

  alias Webapp.{
    Accounts.Member,
    Machines.Machine
  }

  schema "teams" do
    field(:name, :string)
    field(:namespace, :string)
    has_many(:members, Member, on_delete: :delete_all)
    has_many(:users, through: [:members, :user])
    has_many(:machines, Machine, on_delete: :delete_all)

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :namespace])
    |> validate_required([:name, :namespace])
    |> unique_constraint(:name)
    |> unique_constraint(:namespace)
    |> validate_namespace()
  end

  @doc false
  def create_changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :namespace])
    |> validate_required([:name, :namespace])
    |> unique_constraint(:name)
    |> unique_constraint(:namespace)
    |> validate_namespace()
  end

  @doc false
  def add_team_changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :namespace])
    |> validate_required([:name, :namespace])
    |> unique_constraint(:name)
    |> unique_constraint(:namespace)
    |> validate_namespace()
    |> cast_assoc(:members, required: true)
  end

  @doc false
  def update_changeset(team, attrs), do: create_changeset(team, attrs)

  defp validate_namespace(changeset) do
    changeset
    |> validate_required([:namespace])
    |> validate_format(:namespace, ~r/^[a-zA-Z0-9_-]+$/,
      message: "Namespace must only contain letters and numbers and _ -"
    )
    |> unique_constraint(:namespace)
  end
end
