defmodule Webapp.Accounts.Namespace do
  use Ecto.Schema
  import Ecto.Changeset

  alias Webapp.{Accounts.User, Accounts.Group}

  schema "namespaces" do
    field(:namespace, :string)
    field(:private, :boolean, default: false)
  end

  @doc false
  def group_changeset(namespace, attrs) do
    namespace
    |> cast(attrs, [:namespace])
    |> validate_namespace()
    |> put_change(:private, false)
  end

  @doc false
  def user_changeset(namespace, attrs) do
    namespace
    |> cast(attrs, [:namespace])
    |> validate_namespace()
    |> put_change(:private, true)
  end

  defp validate_namespace(changeset) do
    changeset
    |> validate_required([:namespace])
    |> validate_format(:namespace, ~r/^[a-zA-Z0-9_-]+$/,
         message: "Namespace must only contain letters and numbers and _ -"
       )
    |> unique_constraint(:namespace)
  end
end
