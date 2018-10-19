defmodule WebappWeb.MachineControllerTest do
  use WebappWeb.ConnCase

  alias Webapp.Hypervisors

  @create_attrs %{name: "some name", template: "some template"}
  @update_attrs %{name: "some updated name", template: "some updated template"}
  @invalid_attrs %{name: nil, template: nil}

  def fixture(:machine) do
    {:ok, machine} = Hypervisors.create_machine(@create_attrs)
    machine
  end

  describe "index" do
    test "lists all machines", %{conn: conn} do
      conn = get(conn, Routes.machine_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Machines"
    end
  end

  describe "new machine" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.machine_path(conn, :new))
      assert html_response(conn, 200) =~ "New Machine"
    end
  end

  describe "create machine" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.machine_path(conn, :create), machine: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.machine_path(conn, :show, id)

      conn = get(conn, Routes.machine_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Machine"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.machine_path(conn, :create), machine: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Machine"
    end
  end

  describe "edit machine" do
    setup [:create_machine]

    test "renders form for editing chosen machine", %{conn: conn, machine: machine} do
      conn = get(conn, Routes.machine_path(conn, :edit, machine))
      assert html_response(conn, 200) =~ "Edit Machine"
    end
  end

  describe "update machine" do
    setup [:create_machine]

    test "redirects when data is valid", %{conn: conn, machine: machine} do
      conn = put(conn, Routes.machine_path(conn, :update, machine), machine: @update_attrs)
      assert redirected_to(conn) == Routes.machine_path(conn, :show, machine)

      conn = get(conn, Routes.machine_path(conn, :show, machine))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, machine: machine} do
      conn = put(conn, Routes.machine_path(conn, :update, machine), machine: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Machine"
    end
  end

  describe "delete machine" do
    setup [:create_machine]

    test "deletes chosen machine", %{conn: conn, machine: machine} do
      conn = delete(conn, Routes.machine_path(conn, :delete, machine))
      assert redirected_to(conn) == Routes.machine_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.machine_path(conn, :show, machine))
      end
    end
  end

  defp create_machine(_) do
    machine = fixture(:machine)
    {:ok, machine: machine}
  end
end
