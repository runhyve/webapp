defmodule WebappWeb.Ip_poolControllerTest do
  use WebappWeb.ConnCase
  use Webapp.HypervisorCase

  import WebappWeb.AuthCase
  alias Webapp.Networks

  ip_list = """
      192.168.0.1
      192.168.0.2
      192.168.0.3
      192.168.0.4
      192.168.0.5
      192.168.0.6
      192.168.0.7
      192.168.0.8
      192.168.0.9
      192.168.0.10
      192.168.0.11
      192.168.0.12
      192.168.0.13
      192.168.0.14
  """

  @create_attrs %{name: "test_pool", ip_range: "192.168.0.0/28", list: ip_list, gateway: "192.168.0.1", netmask: "255.255.255.240"}
  @update_attrs %{gateway: 43, netmask: 43}
  @invalid_attrs %{gateway: nil, netmask: nil}

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

  def fixture(:ip_pool) do
    {:ok, ip_pool} = Networks.create_ip_pool(@create_attrs)
    ip_pool
  end

  describe "index" do
    test "lists all ip_pools for administrator", %{conn: conn} do
      conn = get(conn, Routes.admin_ip_pool_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing IP Pools"
    end

    test "responses with access denied for unauthorized user", %{conn_user: conn} do
      conn = get(conn, Routes.admin_ip_pool_path(conn, :index))
      assert html_response(conn, 403)
    end
  end

  describe "new ip_pool" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.admin_ip_pool_path(conn, :new))
      assert html_response(conn, 200) =~ "New IP Pool"
    end

    test "responses with access denied for unauthorized user", %{conn_user: conn} do
      conn = get(conn, Routes.admin_ip_pool_path(conn, :new))
      assert html_response(conn, 403)
    end
  end

  describe "create ip_pool" do
    test "redirects to show when data is valid", %{conn: conn, network: network} do
      attrs = %{"network_id" => network.id}
              |> Enum.into(@create_attrs)

      conn = post(conn, Routes.admin_ip_pool_path(conn, :create), ip_pool: attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.admin_ip_pool_path(conn, :show, id)

      conn = get(conn, Routes.admin_ip_pool_path(conn, :show, id))
      assert html_response(conn, 200) =~ "test_pool"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.admin_ip_pool_path(conn, :create), ip_pool: @invalid_attrs)
      assert html_response(conn, 200) =~ "New IP Pool"
    end

    test "responses with access denied for unauthorized user", %{conn_user: conn} do
      conn = post(conn, Routes.admin_ip_pool_path(conn, :create), hypervisor: @invalid_attrs)
      assert html_response(conn, 403)
    end
  end

end
