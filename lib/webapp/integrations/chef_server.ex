defmodule Webapp.Integrations.ChefServer do
  use Ecto.Schema
  import Ecto.Changeset

  alias Webapp.Accounts.Team

  schema "chefservers" do
    field :cacert, :string
    field :enabled, :boolean, default: false
    field :private_key, :string
    field :private_key_input, :string, virtual: true
    field :url, :string
    field :username, :string
    belongs_to :team, Team

    timestamps()
  end

  @doc false
  def changeset(chef_server, attrs) do
    chef_server
    |> cast(attrs, [:url, :enabled, :private_key_input, :username, :team_id])
    |> IO.inspect
    |> put_private_key
    |> IO.inspect
    |> validate_required([:url, :enabled, :private_key, :username, :team_id])
    |> assoc_constraint(:team)
    |> validate_length(:private_key, min: 1600, max: 1800)
    |> validate_format(:private_key, 
        ~r/^-----BEGIN RSA PRIVATE KEY-----[[:ascii:]]+-----END RSA PRIVATE KEY-----$/, 
        message: "Private key is not valid")
  end

  defp put_private_key(%Ecto.Changeset{valid?: true, changes: %{private_key_input: private_key_input}} = changeset) do
    change(changeset, %{private_key: private_key_input})
  end

  defp put_private_key(changeset), do: changeset
end
