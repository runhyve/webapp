defmodule WebappWeb.MachineControllerTest do
  use WebappWeb.ConnCase

  #  @create_attrs %{name: "some name", template: "some template"}
  #  @update_attrs %{name: "some updated name", template: "some updated template"}
  #  @invalid_attrs %{name: nil, template: nil}

  # setup do
  #   conn = build_conn() |> bypass_through(WebappWeb.Router, [:browser]) |> get("/")

  #   user = add_user("user@example.com")

  #   conn_user =
  #     conn
  #     |> add_session(user)
  #     |> send_resp(:ok, "/")

  #   admin = add_admin("admin@example.com")

  #   conn_anon =
  #     conn
  #     |> send_resp(:ok, "/")

  #   {:ok, conn: conn, conn_anon: conn_anon}
  # end

  #  describe "index" do
  #    test "lists all machines", %{conn: conn} do
  #      conn = get(conn, team_path(:machine_path, conn, :index))
  #      assert html_response(conn, 200) =~ "Listing Machines"
  #    end
  #  end
  #
  #  describe "new machine" do
  #    test "renders form", %{conn: conn} do
  #      conn = get(conn, team_path(:machine_path, conn, :new))
  #      assert html_response(conn, 200) =~ "New Machine"
  #    end
  #  end
  #
  #  describe "create machine" do
  #    test "redirects to show when data is valid", %{conn: conn} do
  #      machine = prepare_struct()
  #      conn = post(conn, team_path(:machine_path, conn, :create), machine: machine)
  #
  #      assert %{id: id} = redirected_params(conn)
  #      assert redirected_to(conn) == team_path(:machine_path, conn, :show, id)
  #
  #      conn = get(conn, team_path(:machine_path, conn, :show, id))
  #      assert html_response(conn, 200) =~ machine.name
  #    end
  #
  #    test "renders errors when data is invalid", %{conn: conn} do
  #      conn = post(conn, team_path(:machine_path, conn, :create), machine: @invalid_attrs)
  #      assert html_response(conn, 200) =~ "New Machine"
  #    end
  #  end
  #
  #  describe "edit machine" do
  #    setup [:create_machine]
  #
  #    test "renders form for editing chosen machine", %{conn: conn, machine: machine} do
  #      conn = get(conn, team_path(:machine_path, conn, :edit, machine))
  #      assert html_response(conn, 200) =~ "Edit"
  #    end
  #  end
  #
  #  describe "update machine" do
  #    setup [:create_machine]
  #
  #    test "redirects when data is valid", %{conn: conn, machine: machine} do
  #      conn = put(conn, team_path(:machine_path, conn, :update, machine), machine: @update_attrs)
  #      assert redirected_to(conn) == team_path(:machine_path, conn, :show, machine)
  #
  #      conn = get(conn, team_path(:machine_path, conn, :show, machine))
  #      assert html_response(conn, 200) =~ "some updated name"
  #    end
  #
  #    test "renders errors when data is invalid", %{conn: conn, machine: machine} do
  #      conn = put(conn, team_path(:machine_path, conn, :update, machine), machine: @invalid_attrs)
  #      assert html_response(conn, 200) =~ "Edit"
  #    end
  #  end

  #  describe "delete machine" do
  #    setup [:create_machine]
  #
  #    test "deletes chosen machine", %{conn: conn, machine: machine} do
  #      conn = delete(conn, team_path(:machine_path, conn, :delete, machine))
  #      assert redirected_to(conn) == team_path(:machine_path, conn, :index)
  #      assert_error_sent 404, fn ->
  #        get(conn, team_path(:machine_path, conn, :show, machine))
  #      end
  #    end
  #  end
  #
  #
  #  defp prepare_struct(struct \\ @create_attrs) do
  #    plan = fixture_plan(%{cpu: 2, name: "standard", ram: 1024, storage: 10})
  #    hypervisor_type = fixture_hypervisor_type(%{name: "bhyve"})
  #
  #    hypervisor =
  #      fixture_hypervisor(%{
  #        name: "standard",
  #        ip_address: "192.168.199.254",
  #        hypervisor_type_id: hypervisor_type.id,
  #        fqdn: "http://127.0.0.1:9090"
  #      })
  #
  #    # Update hypervisor_type id with correct one.
  #    machine =
  #      struct
  #      |> Map.put(:hypervisor_id, hypervisor.id)
  #      |> Map.put(:plan_id, plan.id)
  #  end
  #
  #  defp create_machine(_) do
  #    machine = prepare_struct()
  #    machine = fixture_machine(machine)
  #    {:ok, machine: machine}
  #  end
end
