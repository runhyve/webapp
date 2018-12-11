defmodule WebappWeb.DNSController do
  use WebappWeb, :controller

  alias Webapp.{
    DNS,
    DNS.Domain
  }

  def index(conn, params) do
    page = DNS.list_domains(:paginate, params)

    render(conn, "index.html", domains: page.entries, page: page)
  end


  def show(conn, %{"id" => id}) do
    domain = DNS.get_domain!(id, [:records])
    render(conn, "show.html", domain: domain)
  end

end