defmodule WebappWeb.ChefServerControllerTest do
  use WebappWeb.ConnCase

  alias Webapp.Integrations

  @create_attrs %{cacert: "some cacert", enabled: true, private_key: "some private_key", url: "some url", username: "some username"}
  @update_attrs %{cacert: "some updated cacert", enabled: false, private_key: "some updated private_key", url: "some updated url", username: "some updated username"}
  @invalid_attrs %{cacert: nil, enabled: nil, private_key: nil, url: nil, username: nil}

  def fixture(:chef_server) do
    {:ok, chef_server} = Integrations.create_chef_server(@create_attrs)
    chef_server
  end

  describe "index" do
    test "lists all chefservers", %{conn: conn} do
      conn = get(conn, Routes.chef_server_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Chefservers"
    end
  end

  describe "new chef_server" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.chef_server_path(conn, :new))
      assert html_response(conn, 200) =~ "New Chef server"
    end
  end

  describe "create chef_server" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.chef_server_path(conn, :create), chef_server: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.chef_server_path(conn, :show, id)

      conn = get(conn, Routes.chef_server_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Chef server"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.chef_server_path(conn, :create), chef_server: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Chef server"
    end
  end

  describe "edit chef_server" do
    setup [:create_chef_server]

    test "renders form for editing chosen chef_server", %{conn: conn, chef_server: chef_server} do
      conn = get(conn, Routes.chef_server_path(conn, :edit, chef_server))
      assert html_response(conn, 200) =~ "Edit Chef server"
    end
  end

  describe "update chef_server" do
    setup [:create_chef_server]

    test "redirects when data is valid", %{conn: conn, chef_server: chef_server} do
      conn = put(conn, Routes.chef_server_path(conn, :update, chef_server), chef_server: @update_attrs)
      assert redirected_to(conn) == Routes.chef_server_path(conn, :show, chef_server)

      conn = get(conn, Routes.chef_server_path(conn, :show, chef_server))
      assert html_response(conn, 200) =~ "some updated cacert"
    end

    test "renders errors when data is invalid", %{conn: conn, chef_server: chef_server} do
      conn = put(conn, Routes.chef_server_path(conn, :update, chef_server), chef_server: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Chef server"
    end
  end

  describe "delete chef_server" do
    setup [:create_chef_server]

    test "deletes chosen chef_server", %{conn: conn, chef_server: chef_server} do
      conn = delete(conn, Routes.chef_server_path(conn, :delete, chef_server))
      assert redirected_to(conn) == Routes.chef_server_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.chef_server_path(conn, :show, chef_server))
      end
    end
  end

  defp create_chef_server(_) do
    chef_server = fixture(:chef_server)
    {:ok, chef_server: chef_server}
  end
end
