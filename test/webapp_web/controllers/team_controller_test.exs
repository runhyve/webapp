defmodule WebappWeb.TeamControllerTest do
  use WebappWeb.ConnCase

  import WebappWeb.AuthCase
  alias Webapp.Accounts

  @create_attrs %{name: "some name", namespace: %{namespace: "some-name"}}
  #  @update_attrs %{name: "some updated name"}
  #  @invalid_attrs %{name: nil}

  def fixture(:group) do
    {:ok, group} = Accounts.create_team(@create_attrs)
    group
  end

  setup do
    conn = build_conn() |> bypass_through(WebappWeb.Router, [:browser]) |> get("/")

    user = add_user("user@example.com")

    conn_user =
      conn
      |> add_session(user)
      |> send_resp(:ok, "/")

    admin = add_admin("admin@example.com")

    conn =
      conn
      |> add_session(admin)
      |> send_resp(:ok, "/")

    {:ok, conn: conn, conn_user: conn_user}
  end

  describe "index" do
    test "lists all groups", %{conn: conn} do
      conn = get(conn, Routes.team_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Teams"
    end

    test "responses with access denied for unauthorized user", %{conn_user: conn} do
      conn = get(conn, Routes.admin_hypervisor_path(conn, :new))
      assert html_response(conn, 403)
    end
  end

  #  describe "new group" do
  #    test "renders form", %{conn: conn} do
  #      conn = get(conn, Routes.team_path(conn, :new))
  #      assert html_response(conn, 200) =~ "New Team"
  #    end
  #  end
  #
  #  describe "create group" do
  #    test "redirects to show when data is valid", %{conn: conn} do
  #      conn = post(conn, Routes.team_path(conn, :create), group: @create_attrs)
  #
  #      assert %{id: id} = redirected_params(conn)
  #      assert redirected_to(conn) == Routes.team_path(conn, :show, id)
  #
  #      conn = get(conn, Routes.team_path(conn, :show, id))
  #      assert html_response(conn, 200) =~ "Show Team"
  #    end
  #
  #    test "renders errors when data is invalid", %{conn: conn} do
  #      conn = post(conn, Routes.team_path(conn, :create), group: @invalid_attrs)
  #      assert html_response(conn, 200) =~ "New Team"
  #    end
  #  end
  #
  #  describe "edit group" do
  #    setup [:create_team]
  #
  #    test "renders form for editing chosen group", %{conn: conn, group: group} do
  #      conn = get(conn, Routes.team_path(conn, :edit, group))
  #      assert html_response(conn, 200) =~ "Edit Team"
  #    end
  #  end
  #
  #  describe "update group" do
  #    setup [:create_team]
  #
  #    test "redirects when data is valid", %{conn: conn, group: group} do
  #      conn = put(conn, Routes.team_path(conn, :update, group), group: @update_attrs)
  #      assert redirected_to(conn) == Routes.team_path(conn, :show, group)
  #
  #      conn = get(conn, Routes.team_path(conn, :show, group))
  #      assert html_response(conn, 200) =~ "some updated name"
  #    end
  #
  #    test "renders errors when data is invalid", %{conn: conn, group: group} do
  #      conn = put(conn, Routes.team_path(conn, :update, group), group: @invalid_attrs)
  #      assert html_response(conn, 200) =~ "Edit Team"
  #    end
  #  end
  #
  #  describe "delete group" do
  #    setup [:create_team]
  #
  #    test "deletes chosen group", %{conn: conn, group: group} do
  #      conn = delete(conn, Routes.team_path(conn, :delete, group))
  #      assert redirected_to(conn) == Routes.team_path(conn, :index)
  #
  #      assert_error_sent 404, fn ->
  #        get(conn, Routes.team_path(conn, :show, group))
  #      end
  #    end
  #  end

  #  defp create_team(_) do
  #    group = fixture(:group)
  #    {:ok, group: group}
  #  end
end
