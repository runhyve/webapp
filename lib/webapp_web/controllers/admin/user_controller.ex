defmodule WebappWeb.Admin.UserController do
  use WebappWeb, :controller

  alias Webapp.{
    Accounts,
    Accounts.User
  }

  plug :load_and_authorize_resource,
       model: User,
       non_id_actions: [:index, :create, :new]

  def index(conn, _) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

end
