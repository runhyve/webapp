defmodule WebappWeb.LayoutView do
  use WebappWeb, :view

  def version do
    "#{Application.spec(:webapp, :vsn)}-#{Mix.Project.config()[:vcs_version]}"
  end

  def current_session(conn) do
    Plug.Conn.get_session(conn, :phauxth_session_id)
  end
end
