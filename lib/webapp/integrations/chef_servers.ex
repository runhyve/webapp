defmodule Webapp.Integrations.ChefServers do
  @moduledoc """
  The ChefServers module.
  """

  import Ecto.Query, warn: false
  alias Webapp.Repo

  alias Webapp.Integrations.ChefServer
  alias Webapp.Accounts.Team

  @doc """
  Returns the list of chefservers.

  ## Examples

      iex> list_chefservers()
      [%ChefServer{}, ...]

  """
  def list_chefservers do
    Repo.all(ChefServer)
  end

  @doc """
  Returns the list of team's chef servers

  ## Examples

      iex> list_team_chefservers(%Team{})
      [%Machine{}, ...]

  """
  def get_team_chefserver(%Team{} = team) do
    team
    |> Ecto.assoc(:chefservers)
    |> Repo.all()
  end

  @doc """
  Gets a single chef_server.

  Raises `Ecto.NoResultsError` if the Chef server does not exist.

  ## Examples

      iex> get_chef_server!(123)
      %ChefServer{}

      iex> get_chef_server!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chef_server!(id), do: Repo.get!(ChefServer, id)

  @doc """
  Creates a chef_server.

  ## Examples

      iex> create_chef_server(%{field: value})
      {:ok, %ChefServer{}}

      iex> create_chef_server(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chef_server(attrs \\ %{}) do
    %ChefServer{}
    |> ChefServer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a chef_server.

  ## Examples

      iex> update_chef_server(chef_server, %{field: new_value})
      {:ok, %ChefServer{}}

      iex> update_chef_server(chef_server, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chef_server(%ChefServer{} = chef_server, attrs) do
    chef_server
    |> ChefServer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ChefServer.

  ## Examples

      iex> delete_chef_server(chef_server)
      {:ok, %ChefServer{}}

      iex> delete_chef_server(chef_server)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chef_server(%ChefServer{} = chef_server) do
    Repo.delete(chef_server)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chef_server changes.

  ## Examples

      iex> change_chef_server(chef_server)
      %Ecto.Changeset{source: %ChefServer{}}

  """
  def change_chef_server(%ChefServer{} = chef_server) do
    ChefServer.changeset(chef_server, %{})
  end
end
