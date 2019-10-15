defmodule WebappWeb.MemberController do
  use WebappWeb, :controller

  alias Webapp.Accounts

  plug :is_logged_in
  plug :load_team

  def new(conn, _params) do
    team = conn.assigns[:team]

    conn
    |> put_flash(:error, "Not implemented yet.")
    |> redirect(to: Routes.team_path(conn, :show, team))
  end

  def create(%Conn{assigns: %{current_user: _user}} = _conn, %{"team" => _team_params}) do
  end

  def edit(conn, %{"id" => _id}) do
    team = conn.assigns[:team]

    conn
    |> put_flash(:error, "Not implemented yet.")
    |> redirect(to: Routes.team_path(conn, :show, team))
  end

  def update(_conn, %{"id" => _id, "member" => _member_params}) do
  end

  def delete(conn, %{"id" => _id}) do
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
