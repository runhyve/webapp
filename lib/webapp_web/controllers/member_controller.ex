defmodule WebappWeb.MemberController do
  use WebappWeb, :controller

  alias Webapp.{Accounts, Accounts.Team, Accounts.Member}

  plug :is_logged_in
  plug :load_team

  def new(conn, _params) do
    team = conn.assigns[:team]

    conn
    |> put_flash(:error, "Not implemented yet.")
    |> redirect(to: Routes.team_path(conn, :show, team))
  end

  def create(%Conn{assigns: %{current_user: user}} = conn, %{"team" => team_params}) do
  end

  def edit(conn, %{"id" => id}) do
    team = conn.assigns[:team]

    conn
    |> put_flash(:error, "Not implemented yet.")
    |> redirect(to: Routes.team_path(conn, :show, team))
  end

  def update(conn, %{"id" => id, "member" => member_params}) do
  end

  def delete(conn, %{"id" => id}) do
    team = conn.assigns[:team]

    conn
    |> put_flash(:error, "Not implemented yet.")
    |> redirect(to: Routes.team_path(conn, :show, team))
  end

  def load_team(conn, _) do
    try do
      %{"team_id" => id} = conn.params
      team = Accounts.get_team!(id)

      conn
      |> assign(:team, team)
    rescue
      _ ->
        conn
        |> put_flash(:error, "Team was not found.")
        |> redirect(to: Routes.team_path(conn, :index))
    end
  end
end
