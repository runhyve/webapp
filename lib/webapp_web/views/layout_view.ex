defmodule WebappWeb.LayoutView do
  use WebappWeb, :view

  alias Webapp.{Accounts.Team}

  def version do
    "#{Application.spec(:webapp, :vsn)}-#{Mix.Project.config()[:vcs_version]}"
  end

  def current_session(conn) do
    Plug.Conn.get_session(conn, :phauxth_session_id)
  end

  def switch_team_path(conn, %Team{} = team) do
    "/" <> team.namespace <> "/" <> Enum.join(conn.path_info, "/")
  end

  def team_path(:helper, conn, )
end
