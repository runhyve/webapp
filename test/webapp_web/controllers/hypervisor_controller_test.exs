defmodule WebappWeb.HypervisorControllerTest do
  use WebappWeb.ConnCase

  alias Webapp.Hypervisors

  @create_attrs %{ip_address: "some ip_address", name: "some name"}
  @update_attrs %{ip_address: "some updated ip_address", name: "some updated name"}
  @invalid_attrs %{ip_address: nil, name: nil}

  def fixture(:hypervisor) do
    {:ok, hypervisor} = Hypervisors.create_hypervisor(@create_attrs)
    hypervisor
  end

  describe "index" do
    test "lists all hypervisor", %{conn: conn} do
      conn = get(conn, Routes.hypervisor_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Hypervisor"
    end
  end

  describe "new hypervisor" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.hypervisor_path(conn, :new))
      assert html_response(conn, 200) =~ "New Hypervisor"
    end
  end

  describe "create hypervisor" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.hypervisor_path(conn, :create), hypervisor: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.hypervisor_path(conn, :show, id)

      conn = get(conn, Routes.hypervisor_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Hypervisor"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.hypervisor_path(conn, :create), hypervisor: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Hypervisor"
    end
  end

  describe "edit hypervisor" do
    setup [:create_hypervisor]

    test "renders form for editing chosen hypervisor", %{conn: conn, hypervisor: hypervisor} do
      conn = get(conn, Routes.hypervisor_path(conn, :edit, hypervisor))
      assert html_response(conn, 200) =~ "Edit Hypervisor"
    end
  end

  describe "update hypervisor" do
    setup [:create_hypervisor]

    test "redirects when data is valid", %{conn: conn, hypervisor: hypervisor} do
      conn = put(conn, Routes.hypervisor_path(conn, :update, hypervisor), hypervisor: @update_attrs)
      assert redirected_to(conn) == Routes.hypervisor_path(conn, :show, hypervisor)

      conn = get(conn, Routes.hypervisor_path(conn, :show, hypervisor))
      assert html_response(conn, 200) =~ "some updated ip_address"
    end

    test "renders errors when data is invalid", %{conn: conn, hypervisor: hypervisor} do
      conn = put(conn, Routes.hypervisor_path(conn, :update, hypervisor), hypervisor: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Hypervisor"
    end
  end

  describe "delete hypervisor" do
    setup [:create_hypervisor]

    test "deletes chosen hypervisor", %{conn: conn, hypervisor: hypervisor} do
      conn = delete(conn, Routes.hypervisor_path(conn, :delete, hypervisor))
      assert redirected_to(conn) == Routes.hypervisor_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.hypervisor_path(conn, :show, hypervisor))
      end
    end
  end

  defp create_hypervisor(_) do
    hypervisor = fixture(:hypervisor)
    {:ok, hypervisor: hypervisor}
  end
end
