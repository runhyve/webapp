defmodule WebappWeb.TeamPrefixTest do
  use WebappWeb.ConnCase

  import WebappWeb.AuthCase

  alias Webapp.{
    Accounts
  }

  setup %{conn: conn} do
    # prepare connection
    conn =
      conn
      |> bypass_through(WebappWeb.Router, [:browser_auth])
      |> get("/")

    # create user
    user = add_user_confirmed("user@example.com")

    another_user = add_user_confirmed("another_user@example.com")

    # create team
    {:ok, team} =
      Accounts.create_team(%{
        name: "some name",
        namespace: "user-company",
        members: [%{"user_id" => user.id, "role" => "Administrator"}]
      })

    {:ok, another_team} =
      Accounts.create_team(%{
        name: "other name",
        namespace: "other-company",
        members: [%{"user_id" => another_user.id, "role" => "Administrator"}]
      })

    conn = conn |> add_session(user) |> send_resp(:ok, "/")

    {:ok, %{conn: conn, team: team, user: user}}
  end

  test "assigns user team as current_team form url", %{conn: conn, user: user, team: team} do
    conn = get(conn, "/user-company/machines")
    # current_team is loaded without members
    team = Accounts.get_team!(team.id)
    assert conn.assigns[:current_team] == team
  end

  test "team namespace is removed from path_info", %{conn: conn} do
    conn = get(conn, "/user-company/machines")
    assert conn.path_info == ["machines"]
  end

  test "restricted namespaces are not removed from path_info", %{conn: conn} do
    conn = get(conn, "/health")
    assert conn.path_info == ["health"]
  end

  test "responses with not found if team not exists", %{conn: conn} do
    assert_raise Phoenix.Router.NoRouteError,
                 ~r/no route found for GET \/non-existing-company\/machines/,
                 fn ->
                   get(conn, "/non-existing-company/machines")
                 end
  end
end
