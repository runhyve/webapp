defmodule WebappWeb.Admin.TeamController do
  use WebappWeb, :controller

  alias Webapp.{
    Accounts,
    Accounts.Team,
    Accounts.Member
  }

  plug :load_and_authorize_resource,
    model: Team,
    non_id_actions: [:index, :create, :new]

  def index(conn, _params) do
    teams = Accounts.list_teams()
    render(conn, "index.html", teams: teams, user: nil)
  end
end
