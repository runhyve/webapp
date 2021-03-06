defmodule Webapp.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Webapp.{
    Repo,
    Accounts.Registration,
    Accounts.User,
    Accounts.Team,
    Accounts.SSHPublicKey,
    Notifications.Notifications,
    Sessions,
    Sessions.Session
  }

  @doc """
  Returns the list of users.
  """
  def list_users(preloads \\ []) do
    Repo.all(User)
    |> Repo.preload(preloads)
  end

  @doc """
  Gets a single user.
  """
  def get_user(id, preloads \\ []) do
    Repo.get(User, id)
    |> Repo.preload(preloads)
  end

  @doc """
  Gets a user based on the params.

  This is used by Phauxth to get user information.
  """
  def get_by(_conditions, preloads \\ [])

  def get_by(%{"session_id" => session_id}, preloads) do
    with %Session{user_id: user_id} <- Sessions.get_session(session_id),
         do: get_user(user_id, preloads)
  end

  def get_by(%{"email" => email}, preloads) do
    Repo.get_by(User, email: email)
    |> Repo.preload(preloads)
  end

  def get_by(%{"user_id" => user_id}, preloads) do
    Repo.get(User, user_id)
    |> Repo.preload(preloads)
  end

  def get_by(%{"namespace" => namespace}, preloads) do
    Repo.one(
      from(u in User,
        join: n in assoc(u, :namespace),
        where: n.namespace == ^namespace
      )
    )
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a session for the user.

  This is used by Phauxth.Remember.
  """
  def create_session(attrs), do: Sessions.create_session(attrs)

  @doc """
  Creates a user.
  """
  def register_user(attrs) do
    result = %Registration{}
    |> Registration.changeset(attrs)
    |> Registration.registration(attrs)
    |> Repo.transaction()

    Notifications.publish(:info, "New user #{attrs["user_name"]} registered.")

    result
  end

  @doc """
  Updates a user.
  """
  def update_user(%User{} = user, attrs) do
    result = user
    |> User.update_changeset(attrs)
    |> Repo.update()

    Notifications.publish(:info, "User #{user.name} updated.")

    result
  end

  @doc """
  Deletes a User.
  """
  def delete_user(%User{} = user) do
    Notifications.publish(:info, "User #{user.name} deleted.")
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Confirms a user's email.
  """
  def confirm_user(%User{} = user) do
    user |> User.confirm_changeset() |> Repo.update()
  end

  @doc """
  Makes a password reset request.
  """
  def create_password_reset(attrs) do
    with %User{} = user <- get_by(attrs) do
      user
      |> User.password_reset_changeset(DateTime.utc_now() |> DateTime.truncate(:second))
      |> Repo.update()
    end
  end

  @doc """
  Updates a user's password.
  """
  def update_password(%User{} = user, attrs) do
    Sessions.delete_user_sessions(user)

    user
    |> User.create_changeset(attrs)
    |> User.password_reset_changeset(nil)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking registration changes.
  """
  def change_registration(%Registration{} = registration) do
    Registration.changeset(registration, %{})
  end

  def user_first_team(%User{} = user) do
    Repo.one(
      from(t in Team,
        join: m in assoc(t, :members),
        where: m.user_id == ^user.id,
        limit: 1,
        order_by: m.inserted_at
      )
    )
  end

  @doc """
  Returns the list of teams.

  ## Examples

      iex> list_teams()
      [%Team{}, ...]

  """
  def list_teams(preloads \\ []) do
    Repo.all(Team)
    |> Repo.preload(preloads)
  end

  @doc """
  Returns the list of user's teams.
  """
  def list_user_teams(preloads \\ []) do
    Repo.all(Team)
    |> Repo.preload(preloads)
  end

  @doc """
  Gets a single team.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get_team!(123)
      %Team{}

      iex> get_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team!(id, preloads \\ []) do
    Repo.get!(Team, id)
    |> Repo.preload(preloads)
  end

  @doc """
  Gets a team based on the params.
  """
  def get_team_by(conditions, preloads \\ [])

  def get_team_by(%{"namespace" => name}, preloads) do
    Repo.get_by(Team, namespace: name)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a team with first member.

  ## Examples

      iex> create_team(%{field: value})
      {:ok, %Team{}}

      iex> create_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team(attrs \\ %{}) do
    result = %Team{}
    |> Team.add_team_changeset(attrs)
    |> Repo.insert()

    Notifications.publish(:info, "Team #{attrs["name"]} created.")

    result
  end

  @doc """
  Updates a team.

  ## Examples

      iex> update_team(team, %{field: new_value})
      {:ok, %Team{}}

      iex> update_team(team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team(%Team{} = team, attrs) do
    team
    |> Team.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Team.

  ## Examples

      iex> delete_team(team)
      {:ok, %Team{}}

      iex> delete_team(team)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team(%Team{} = team) do
    Notifications.publish(:info, "Team #{team.name} deleted.")
    Repo.delete(team)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team changes.

  ## Examples

      iex> change_team(team)
      %Ecto.Changeset{source: %Team{}}

  """
  def change_team(%Team{} = team) do
    Team.changeset(team, %{})
  end

  @doc """
  Returns the list of ssh_public_keys.

  ## Examples

      iex> list_ssh_public_keys()
      [%SSHPublicKey{}, ...]

  """
  def list_ssh_public_keys do
    Repo.all(SSHPublicKey)
  end

  @doc """
  Returns the list of ssh_public_keys belonging to the user.

  ## Examples

      iex> list_ssh_public_keys(user_id)
      [%SSHPublicKey{}, ...]

  """
  def list_user_ssh_public_keys(%User{} = user) do
    user
    |> Ecto.assoc(:ssh_public_keys)
    |> Repo.all()
  end

  @doc """
  Gets a single ssh_public_key.

  Raises `Ecto.NoResultsError` if the Ssh public key does not exist.

  ## Examples

      iex> get_ssh_public_key!(123)
      %SSHPublicKey{}
      iex> get_ssh_public_key!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ssh_public_key!(id), do: Repo.get!(SSHPublicKey, id)

  @doc """
  Creates a ssh_public_key.

  ## Examples

      iex> create_ssh_public_key(%{field: value})
      {:ok, %SSHPublicKey{}}

      iex> create_ssh_public_key(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ssh_public_key(user, attrs \\ %{}) do
    %SSHPublicKey{user_id: user.id}
    |> SSHPublicKey.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a SSHPublicKey.

  ## Examples

      iex> delete_ssh_public_key(ssh_public_key)
      {:ok, %SSHPublicKey{}}

      iex> delete_ssh_public_key(ssh_public_key)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ssh_public_key(%SSHPublicKey{} = ssh_public_key) do
    Repo.delete(ssh_public_key)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ssh_public_key changes.

  ## Examples

      iex> change_ssh_public_key(ssh_public_key)
      %Ecto.Changeset{source: %SSHPublicKey{}}

  """
  def change_ssh_public_key(%SSHPublicKey{} = ssh_public_key) do
    SSHPublicKey.changeset(ssh_public_key, %{})
  end
end
