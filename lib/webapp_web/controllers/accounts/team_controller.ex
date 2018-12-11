defmodule WebappWeb.TeamController do
  use WebappWeb, :controller

  alias Webapp.{Accounts, Accounts.Team, Accounts.Member}

  plug :is_logged_in
  plug :is_admin? when action in [:index, :delete]

  def index(conn, _params) do
    teams = Accounts.list_teams()
    render(conn, "index.html", teams: teams, user: nil)
  end

  def new(conn, _params) do
    changeset = Accounts.change_team(%Team{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(%Conn{assigns: %{current_user: user}} = conn, %{"team" => team_params}) do
    team_params =
      Map.merge(team_params, %{"members" => [%{"user_id" => user.id, "role" => "Administrator"}]})

    case Accounts.create_team(team_params) do
      {:ok, team} ->
        conn
        |> put_flash(:info, "Team created successfully.")
        |> redirect(to: Routes.team_path(conn, :show, team))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    team = Accounts.get_team!(id, members: [:user])
    render(conn, "show.html", team: team)
  end

  def edit(conn, %{"id" => id}) do
    team = Accounts.get_team!(id)
    changeset = Accounts.change_team(team)
    render(conn, "edit.html", team: team, changeset: changeset)
  end

  def update(conn, %{"id" => id, "team" => team_params}) do
    team = Accounts.get_team!(id)

    case Accounts.update_team(team, team_params) do
      {:ok, team} ->
        conn
        |> put_flash(:info, "Team updated successfully.")
        |> redirect(to: Routes.team_path(conn, :show, team))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", team: team, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    team = Accounts.get_team!(id)
    {:ok, _team} = Accounts.delete_team(team)

    conn
    |> put_flash(:info, "Team deleted successfully.")
    |> redirect(to: Routes.team_path(conn, :index))
  end
end
