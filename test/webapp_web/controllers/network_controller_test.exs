defmodule WebappWeb.NetworkControllerTest do
  use WebappWeb.ConnCase

  alias Webapp.Hypervisors

  @create_attrs %{name: "some name", network: "some network"}
  @update_attrs %{name: "some updated name", network: "some updated network"}
  @invalid_attrs %{name: nil, network: nil}

  def fixture(:network) do
    {:ok, network} = Hypervisors.create_network(@create_attrs)
    network
  end

  describe "index" do
    test "lists all networks", %{conn: conn} do
      conn = get(conn, Routes.network_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Networks"
    end
  end

  describe "new network" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.network_path(conn, :new))
      assert html_response(conn, 200) =~ "New Network"
    end
  end

  describe "create network" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.network_path(conn, :create), network: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.network_path(conn, :show, id)

      conn = get(conn, Routes.network_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Network"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.network_path(conn, :create), network: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Network"
    end
  end

  describe "edit network" do
    setup [:create_network]

    test "renders form for editing chosen network", %{conn: conn, network: network} do
      conn = get(conn, Routes.network_path(conn, :edit, network))
      assert html_response(conn, 200) =~ "Edit Network"
    end
  end

  describe "update network" do
    setup [:create_network]

    test "redirects when data is valid", %{conn: conn, network: network} do
      conn = put(conn, Routes.network_path(conn, :update, network), network: @update_attrs)
      assert redirected_to(conn) == Routes.network_path(conn, :show, network)

      conn = get(conn, Routes.network_path(conn, :show, network))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, network: network} do
      conn = put(conn, Routes.network_path(conn, :update, network), network: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Network"
    end
  end

  describe "delete network" do
    setup [:create_network]

    test "deletes chosen network", %{conn: conn, network: network} do
      conn = delete(conn, Routes.network_path(conn, :delete, network))
      assert redirected_to(conn) == Routes.network_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.network_path(conn, :show, network))
      end
    end
  end

  defp create_network(_) do
    network = fixture(:network)
    {:ok, network: network}
  end
end
