defmodule WebappWeb.TeamContextTest do
  use WebappWeb.ConnCase

  import WebappWeb.AuthCase
  alias Webapp.{
    Accounts
  }
  
  setup %{conn: conn} do
    # prepare connection
    conn = conn 
    |> bypass_through(WebappWeb.Router, [:browser_auth]) 
    |> get("/")

    # create user
    user = add_user_confirmed("user@example.com")

    another_user = add_user_confirmed("another_user@example.com")

    # create team
    {:ok, team} = Accounts.create_team(%{
      name: "some name", 
      namespace: "user-company",
      members: [%{"user_id" => user.id, "role" => "Administrator"}]
    })

    {:ok, another_team} = Accounts.create_team(%{
      name: "other name", 
      namespace: "other-company",
      members: [%{"user_id" => another_user.id, "role" => "Administrator"}]
    })

    conn = conn |> add_session(user) |> send_resp(:ok, "/")

    {:ok, %{conn: conn, team: team, user: user}}
  end

  test "first user team is assigned as current_team if namespace is not provided in url", %{conn: conn, user: user} do
    conn = get(conn, "/")
    team = Accounts.user_first_team(user)
    assert conn.assigns[:current_team] == team
  end
  
  test "current_team is taken form url", %{conn: conn, user: user, team: team} do   
    conn = get(conn, "/user-company/machines")
    # current_team is loaded without members
    team = Accounts.get_team!(team.id)
    assert conn.assigns[:current_team] == team   
  end

  test "user can not access other teams", %{conn: conn, user: user, team: team} do
    conn = get(conn, "/other-company/machines")

    assert conn.halted
    assert conn.status == 302
    assert redirected_to(conn) == "/machines"
  end
end
