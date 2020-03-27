defmodule WebappWeb.PlanControllerTest do
  use WebappWeb.ConnCase

  import WebappWeb.AuthCase

  @create_attrs %{cpu: 42, name: "some name", ram: 42, storage: 42, price: 10, currency_code: "USD", period_unit: "month"}
  @update_attrs %{cpu: 43, name: "some updated name", ram: 43, storage: 43, price: 20, currency_code: "USD", period_unit: "month"}
  @invalid_attrs %{cpu: nil, name: nil, ram: nil, storage: nil, price: nil}

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
    test "lists all plans", %{conn: conn} do
      conn = get(conn, Routes.admin_plan_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Plans"
    end

    test "responses with access denied for unauthorized user", %{conn_user: conn} do
      conn = get(conn, Routes.admin_hypervisor_path(conn, :index))
      assert html_response(conn, 403)
    end
  end

  describe "new plan" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.admin_plan_path(conn, :new))
      assert html_response(conn, 200) =~ "New Plan"
    end

    test "responses with access denied for unauthorized user", %{conn_user: conn} do
      conn = get(conn, Routes.admin_hypervisor_path(conn, :index))
      assert html_response(conn, 403)
    end
  end

  describe "create plan" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.admin_plan_path(conn, :create), plan: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.admin_plan_path(conn, :show, id)

      conn = get(conn, Routes.admin_plan_path(conn, :show, id))
      assert html_response(conn, 200) =~ @create_attrs.name
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.admin_plan_path(conn, :create), plan: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Plan"
    end

    test "responses with access denied for unauthorized user", %{conn_user: conn} do
      conn = get(conn, Routes.admin_hypervisor_path(conn, :index))
      assert html_response(conn, 403)
    end
  end

  describe "edit plan" do
    setup [:create_plan]

    test "renders form for editing chosen plan", %{conn: conn, plan: plan} do
      conn = get(conn, Routes.admin_plan_path(conn, :edit, plan))
      assert html_response(conn, 200) =~ plan.name
    end

    test "responses with access denied for unauthorized user", %{conn_user: conn} do
      conn = get(conn, Routes.admin_hypervisor_path(conn, :index))
      assert html_response(conn, 403)
    end
  end

  describe "update plan" do
    setup [:create_plan]

    test "redirects when data is valid", %{conn: conn, plan: plan} do
      conn = put(conn, Routes.admin_plan_path(conn, :update, plan), plan: @update_attrs)
      assert redirected_to(conn) == Routes.admin_plan_path(conn, :show, plan)

      conn = get(conn, Routes.admin_plan_path(conn, :show, plan))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, plan: plan} do
      conn = put(conn, Routes.admin_plan_path(conn, :update, plan), plan: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit"
    end

    test "responses with access denied for unauthorized user", %{conn_user: conn} do
      conn = get(conn, Routes.admin_hypervisor_path(conn, :index))
      assert html_response(conn, 403)
    end
  end

  describe "delete plan" do
    setup [:create_plan]

    test "deletes chosen plan", %{conn: conn, plan: plan} do
      conn = delete(conn, Routes.admin_plan_path(conn, :delete, plan))
      assert redirected_to(conn) == Routes.admin_plan_path(conn, :index)

      conn = get(conn, Routes.admin_plan_path(conn, :show, plan))
      assert html_response(conn, 404)
    end

    test "responses with access denied for unauthorized user", %{conn_user: conn} do
      conn = get(conn, Routes.admin_hypervisor_path(conn, :index))
      assert html_response(conn, 403)
    end
  end

  defp create_plan(_) do
    plan = fixture_plan(@create_attrs)
    {:ok, plan: plan}
  end
end
