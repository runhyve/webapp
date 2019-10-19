defmodule Webapp.Integrations.ChefServer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chefservers" do
    field :cacert, :string
    field :enabled, :boolean, default: false
    field :private_key, :string
    field :url, :string
    field :username, :string
    field :team_id, :id

    timestamps()
  end

  @doc false
  def changeset(chef_server, attrs) do
    chef_server
    |> cast(attrs, [:url, :cacert, :enabled, :private_key, :username, :team_id])
    |> validate_required([:url, :cacert, :enabled, :private_key, :username, :team_id])
  end
end
