defmodule WebappWeb.RegionControllerTest do
  use WebappWeb.ConnCase

  alias Webapp.Regions
  import WebappWeb.AuthCase

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

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

  def fixture(:region) do
    {:ok, region} = Regions.create_region(@create_attrs)
    region
  end

  describe "index" do
    test "lists all regions", %{conn: conn} do
      conn = get(conn, Routes.admin_region_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Regions"
    end

    test "responses with access denied for unauthorized user", %{conn_user: conn} do
      conn = get(conn, Routes.admin_region_path(conn, :index))
      assert html_response(conn, 403)
    end
  end

  describe "new region" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.admin_region_path(conn, :new))
      assert html_response(conn, 200) =~ "New Region"
    end

    test "responses with access denied for unauthorized user", %{conn_user: conn} do
      conn = get(conn, Routes.admin_region_path(conn, :new))
      assert html_response(conn, 403)
    end
  end

  describe "create region" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.admin_region_path(conn, :create), region: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.admin_region_path(conn, :show, id)

      conn = get(conn, Routes.admin_region_path(conn, :show, id))
      assert html_response(conn, 200) =~ "some name"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.admin_region_path(conn, :create), region: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Region"
    end

    test "responses with access denied for unauthorized user", %{conn_user: conn} do
      conn = post(conn, Routes.admin_region_path(conn, :create), hypervisor: @invalid_attrs)
      assert html_response(conn, 403)
    end
  end

  describe "edit region" do
    setup [:create_region]

    test "renders form for editing chosen region", %{conn: conn, region: region} do
      conn = get(conn, Routes.admin_region_path(conn, :edit, region))
      assert html_response(conn, 200) =~ "Save"
    end

    test "responses with access denied for unauthorized user", %{
      conn_user: conn,
      region: region
    } do
      conn = get(conn, Routes.admin_region_path(conn, :edit, region))
      assert html_response(conn, 403)
    end
  end

  describe "update region" do
    setup [:create_region]

    test "redirects when data is valid", %{conn: conn, region: region} do
      conn = put(conn, Routes.admin_region_path(conn, :update, region), region: @update_attrs)
      assert redirected_to(conn) == Routes.admin_region_path(conn, :show, region)

      conn = get(conn, Routes.admin_region_path(conn, :show, region))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, region: region} do
      conn = put(conn, Routes.admin_region_path(conn, :update, region), region: @invalid_attrs)
      assert html_response(conn, 200) =~ "Save"
    end

    test "responses with access denied for unauthorized user", %{
      conn_user: conn,
      region: region
    } do
      conn =
        put(conn, Routes.admin_region_path(conn, :update, region),
          region: @update_attrs
        )

      assert html_response(conn, 403)
    end
  end

  describe "delete region" do
    setup [:create_region]

    test "deletes chosen region", %{conn: conn, region: region} do
      conn = delete(conn, Routes.admin_region_path(conn, :delete, region))
      assert redirected_to(conn) == Routes.admin_region_path(conn, :index)
      conn = get(conn, Routes.admin_region_path(conn, :show, region))
      assert conn.status == 404
    end
  end

  defp create_region(_) do
    region = fixture(:region)
    {:ok, region: region}
  end
end
