defmodule WebappWeb.PageControllerTest do
  use WebappWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Runhyve"
  end
end
