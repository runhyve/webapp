defmodule Webapp.Accounts.User do
  use WebappWeb, :model

  alias Webapp.{
    Sessions.Session,
    Accounts.User,
    Accounts.Team,
    Accounts.Member,
    Types.UserRole
  }

  schema "users" do
    field(:email, :string)
    field(:name, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    field(:confirmed_at, :utc_datetime)
    field(:reset_sent_at, :utc_datetime)
    field(:role, UserRole, default: "User")

    has_many(:sessions, Session, on_delete: :delete_all)
    has_many(:memberships, Member, on_delete: :delete_all)
    has_many(:teams, through: [:memberships, :team])

    timestamps()
  end

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :name])
    |> validate_required([:email, :name])
    |> unique_constraint(:name)
    |> unique_email()
  end

  def create_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password, :name])
    |> validate_required([:email, :password, :name])
    |> unique_constraint(:name)
    |> unique_email()
    |> validate_password(:password)
    |> put_pass_hash()
  end

  def update_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :name, :role])
    |> validate_required([:email, :name])
    |> unique_constraint(:name)
    |> unique_email()
  end

  def confirm_changeset(user) do
    change(user, %{confirmed_at: DateTime.utc_now() |> DateTime.truncate(:second)})
  end

  def password_reset_changeset(user, reset_sent_at) do
    change(user, %{reset_sent_at: reset_sent_at})
  end

  defp unique_email(changeset) do
    validate_format(changeset, :email, ~r/@/)
    |> validate_length(:email, max: 254)
    |> unique_constraint(:email)
  end

  # In the function below, strong_password? just checks that the password
  # is at least 8 characters long.
  # See the documentation for NotQwerty123.PasswordStrength.strong_password?
  # for a more comprehensive password strength checker.
  defp validate_password(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, password ->
      case strong_password?(password) do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || msg}]
      end
    end)
  end

  # If you are using Bcrypt or Pbkdf2, change Argon2 to Bcrypt or Pbkdf2
  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Comeonin.Argon2.add_hash(password))
  end

  defp put_pass_hash(changeset), do: changeset

  defp strong_password?(password) when byte_size(password) > 7 do
    {:ok, password}
  end

  defp strong_password?(_), do: {:error, "The password is too short"}
end
