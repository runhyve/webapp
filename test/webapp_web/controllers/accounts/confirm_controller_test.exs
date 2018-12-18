defmodule WebappWeb.ConfirmControllerTest do
  use WebappWeb.ConnCase

  import WebappWeb.AuthCase

  setup %{conn: conn} do
    conn = conn |> bypass_through(Webapp.Router, :browser) |> get("/")
    add_user("arthur@example.com")
    {:ok, %{conn: conn}}
  end

  test "confirmation succeeds for correct key", %{conn: conn} do
    conn = get(conn, Routes.user_path(conn, :confirm, key: gen_key("arthur@example.com")))
    assert conn.private.phoenix_flash["info"] =~ "account has been confirmed"
    assert redirected_to(conn) == Routes.session_path(conn, :new)
  end

  test "confirmation fails for incorrect key", %{conn: conn} do
    conn = get(conn, Routes.user_path(conn, :confirm, key: "garbage"))
    assert conn.private.phoenix_flash["error"] =~ "Invalid credentials"
    assert redirected_to(conn) == Routes.session_path(conn, :new)
  end

  test "confirmation fails for incorrect email", %{conn: conn} do
    conn = get(conn, Routes.user_path(conn, :confirm, key: gen_key("gerald@example.com")))
    assert conn.private.phoenix_flash["error"] =~ "Invalid credentials"
    assert redirected_to(conn) == Routes.session_path(conn, :new)
  end
end
