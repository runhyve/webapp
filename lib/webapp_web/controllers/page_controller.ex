defmodule WebappWeb.PageController do
  use WebappWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def health(conn, _) do
    try do
      Webapp.Hypervisors.list_hypervisors()
      send_resp(conn, 200, "OK")
    rescue
      _e -> send_resp(conn, 500, "Internal Server Error")
    end
  end
end
