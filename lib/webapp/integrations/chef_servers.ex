defmodule Webapp.Integrations.ChefServers do
  @moduledoc """
  The ChefServers module.
  """

  import Ecto.Query, warn: false
  import Logger
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

  @doc """
  Make API call to Chef Server

  ## Examples
      iex> chef_request(chef_server)
      {:ok, %Response{}}
  """
  defp chef_request(%ChefServer{} = chef_server, cmd) do
    File.write!("./private.key", chef_server.private_key)

    {stdout, exit_code} = System.cmd("knife", cmd ++ ["-k", "./private.key", "-F", "json", "-s", chef_server.url])
    Logger.debug(["Chef call: ", cmd])
    Jason.decode(stdout)
  end

  @doc """
  Get list of nodes from Chef Server
  ## Examples
      iex> chef_get_nodes(chef_server)
      {:ok, %Response}
  """
  def chef_nodes_list(%ChefServer{} = chef_server) do
    case chef_request(chef_server, ["node", "list"]) do
      {:ok, response} ->
        response
      {:error, error} ->
        []
    end
  end

  @doc """
  Get statuses of nodes from Chef Server
  ## Examples
      iex> chef_status(chef_server)
      {:ok, %Response}
  """
  def chef_status(%ChefServer{} = chef_server) do
    case chef_request(chef_server, ["status"]) do
      {:ok, response} ->
        response
      {:error, error} ->
        []
    end
  end

  @doc """
  Get list of environments of nodes from Chef Server
  ## Examples
      iex> chef_environment_list(chef_server)
      {:ok, %Response}
  """
  def chef_environments_list(%ChefServer{} = chef_server) do
    case chef_request(chef_server, ["environment", "list"]) do
      {:ok, response} ->
        response
      {:error, error} ->
        []
    end
  end

  @doc """
  Get list of environments of nodes from Chef Server
  ## Examples
      iex> chef_role_lis(chef_server)
      {:ok, %Response}
  """
  def chef_roles_list(%ChefServer{} = chef_server) do
    case chef_request(chef_server, ["role", "list"]) do
      {:ok, response} ->
        response
      {:error, error} ->
        []
    end
  end

  @doc """
  Bootstrap node against Chef
  ## Examples
      iex> chef_boostrap(chef_server, fqdn, ["role['base']", "role['kubernetes-node']"], "production")
  """
  def chef_bootstrap(%ChefServer{} = chef_server, fqdn, runlist \\ [], environment \\ "_default") do
    chef_request(chef_server, ["bootstrap", fqdn, "-r", runlist, "-E", environment])
  end
end
