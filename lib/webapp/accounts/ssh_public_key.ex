defmodule Webapp.Accounts.SSHPublicKey do
  use Ecto.Schema
  import Ecto.Changeset

  alias Webapp.Accounts.User

  schema "ssh_public_keys" do
    field(:title, :string)
    field(:ssh_public_key, :string)
    field(:fingerprint, :string)
    belongs_to(:user, User)

    timestamps()
  end

  @doc false
  def changeset(ssh_public_key, attrs) do
    ssh_public_key
    |> cast(attrs, [:title, :ssh_public_key, :fingerprint, :user_id])
    |> validate_required([:title, :ssh_public_key])
    |> assoc_constraint(:user)
    |> validate_length(:ssh_public_key, min: 300, max: 1000)
    |> validate_length(:title, min: 3, max: 128)
    |> validate_format(:ssh_public_key, ~r/ssh-rsa AAAA[0-9A-Za-z+\/]+[=]{0,3} ([^@]+@[^@]+)/,
      message: "SSH public key is not valid"
    )
    |> add_fingerprint
    # TODO: this doesn't work - error is at database level
    |> unique_constraint(:fingerprint, name: :ssh_public_keys__user_id)
  end

  defp add_fingerprint(
         %Ecto.Changeset{valid?: true, changes: %{ssh_public_key: ssh_public_key}} = changeset
       ) do
    try do
      [{pk, _attributes}] = :public_key.ssh_decode(ssh_public_key, :public_key)
      changeset
      |> change(%{fingerprint: to_string(:public_key.ssh_hostkey_fingerprint(pk))})
    rescue
      _error ->
        changeset
        |> add_error(:ssh_public_key, "SSH public key is not valid")
    end
  end

  defp add_fingerprint(changeset), do: changeset
end
