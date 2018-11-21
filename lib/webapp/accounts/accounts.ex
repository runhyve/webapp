defmodule Webapp.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Webapp.{
    Repo,
    Accounts.User,
    Accounts.Group,
    Accounts.Namespace,
    Sessions,
    Sessions.Session
  }

  @doc """
  Returns the list of users.
  """
  def list_users(preloads \\ [:namespace]) do
    Repo.all(User)
    |> Repo.preload(preloads)
  end

  @doc """
  Gets a single user.
  """
  def get_user(id, preloads \\ [:namespace]) do
    Repo.get(User, id)
    |> Repo.preload(preloads)
  end

  @doc """
  Gets a user based on the params.

  This is used by Phauxth to get user information.
  """
  def get_by(_conditions, preloads \\ [:namespace])

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
    Repo.one(from u in User,
             join: n in assoc(u, :namespace),
             where: n.namespace == ^namespace)
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
  def create_user(attrs) do
    %User{}
    |> User.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.
  """
  def delete_user(%User{} = user) do
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
  Gets a namespace based on the params.
  """
  def get_namespace_by(%{"namespace" => name}, preloads \\ []) do
    Repo.get_by(Namespace, namespace: name)
    |> Repo.preload(preloads)
  end

  @doc """
  Returns the list of groups.

  ## Examples

      iex> list_groups()
      [%Group{}, ...]

  """
  def list_groups(preloads \\ [:namespace]) do
    Repo.all(Group)
    |> Repo.preload(preloads)
  end

  @doc """
  Gets a single group.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group!(123)
      %Group{}

      iex> get_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group!(id, preloads \\ [:namespace]) do
    Repo.get!(Group, id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group(attrs \\ %{}) do
    %Group{}
    |> Group.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a group.

  ## Examples

      iex> update_group(group, %{field: new_value})
      {:ok, %Group{}}

      iex> update_group(group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group(%Group{} = group, attrs) do
    group
    |> Group.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group(%Group{} = group) do
    Repo.delete(group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group changes.

  ## Examples

      iex> change_group(group)
      %Ecto.Changeset{source: %Group{}}

  """
  def change_group(%Group{} = group) do
    Group.changeset(group, %{})
  end
end
