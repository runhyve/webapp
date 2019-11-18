defmodule WebappWeb.ChefServerController do
  use WebappWeb, :controller

  alias Webapp.Integrations.ChefServer
  import Webapp.Integrations.ChefServers
  alias Webapp.Accounts.Team
  import Ecto.Changeset

  plug :load_and_authorize_resource,
    current_user: :current_member,
    model: ChefServer,
    non_id_actions: [:index, :create, :new]

  def index(%Conn{assigns: %{current_team: %Team{} = team}} = conn, _params) do
    chefservers = get_team_chefserver(team)

    # If team has chef server then display it, if not then show form to create one
    if not Enum.empty?(chefservers) do
      chef_server = hd(chefservers) # We support only one chef server per team
      nodes = chef_nodes_list(chef_server)
      environments = chef_environments_list(chef_server)
      roles = chef_roles_list(chef_server)
      render(conn, "show.html", chef_server: get_chef_server!(chef_server.id), nodes: nodes, environments: environments, roles: roles)
    else
      changeset = change_chef_server(%ChefServer{})
      render(conn, "new.html", changeset: changeset)
    end
  end

  def new(conn, _params) do
    changeset = change_chef_server(%ChefServer{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(%Conn{assigns: %{current_team: %Team{} = team}} = conn, %{"chef_server" => chef_server_params}) do
    params = chef_server_params
    |> Map.put("team_id", team.id)

    case create_chef_server(params) do
      {:ok, chef_server} ->
        conn
        |> put_flash(:info, "Chef server created successfully.")
        |> redirect(to: Routes.chef_server_path(conn, :show, chef_server))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    chef_server = get_chef_server!(id)
    nodes = chef_nodes_list(chef_server)
    render(conn, "show.html", chef_server: chef_server, nodes: nodes)
  end

  def edit(conn, %{"id" => id}) do
    chef_server = get_chef_server!(id)
    changeset = change_chef_server(chef_server)
    render(conn, "edit.html", chef_server: chef_server, changeset: changeset)
  end

  def update(conn, %{"id" => id, "chef_server" => chef_server_params}) do
    chef_server = get_chef_server!(id)

    case update_chef_server(chef_server, chef_server_params) do
      {:ok, chef_server} ->
        conn
        |> put_flash(:info, "Chef server updated successfully.")
        |> redirect(to: Routes.chef_server_path(conn, :show, chef_server))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", chef_server: chef_server, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    chef_server = get_chef_server!(id)
    {:ok, _chef_server} = delete_chef_server(chef_server)

    conn
    |> put_flash(:info, "Chef server deleted successfully.")
    |> redirect(to: Routes.chef_server_path(conn, :index))
  end
end
