defmodule WebappWeb.HypervisorControllerTest do
  use WebappWeb.ConnCase

  import WebappWeb.AuthCase

  @create_attrs %{
    name: "some name",
    hypervisor_type_id: 0,
    fqdn: "http://127.0.0.1.xip.io:9090",
    tls: true,
    webhook_token: "123qweASD"
  }
  @update_attrs %{
    name: "some updated name",
    fqdn: "http://127.0.0.1:9090",
    tls: true
  }
  @invalid_attrs %{ip_address: nil, name: nil, hypervisor_type_id: nil, fqdn: nil}

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
    test "lists all hypervisor for administrator", %{conn: conn} do
      conn = get(conn, Routes.admin_hypervisor_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Hypervisor"
    end

    test "responses with access denied for unauthorized user", %{conn_user: conn} do
      conn = get(conn, Routes.admin_hypervisor_path(conn, :index))
      assert html_response(conn, 403)
    end
  end

  describe "new hypervisor" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.admin_hypervisor_path(conn, :new))
      assert html_response(conn, 200) =~ "New Hypervisor"
    end

    test "responses with access denied for unauthorized user", %{conn_user: conn} do
      conn = get(conn, Routes.admin_hypervisor_path(conn, :new))
      assert html_response(conn, 403)
    end
  end

  describe "create hypervisor" do
    test "redirects to show when data is valid", %{conn: conn} do
      hypervisor = prepare_struct()
      conn = post(conn, Routes.admin_hypervisor_path(conn, :create), hypervisor: hypervisor)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.admin_hypervisor_path(conn, :show, id)

      conn = get(conn, Routes.admin_hypervisor_path(conn, :show, id))
      assert html_response(conn, 200) =~ hypervisor.name
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.admin_hypervisor_path(conn, :create), hypervisor: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Hypervisor"
    end

    test "responses with access denied for unauthorized user", %{conn_user: conn} do
      conn = post(conn, Routes.admin_hypervisor_path(conn, :create), hypervisor: @invalid_attrs)
      assert html_response(conn, 403)
    end
  end

  describe "edit hypervisor" do
    setup [:create_hypervisor]

    test "renders form for editing chosen hypervisor", %{conn: conn, hypervisor: hypervisor} do
      conn = get(conn, Routes.admin_hypervisor_path(conn, :edit, hypervisor))
      assert html_response(conn, 200) =~ "Edit"
    end

    test "responses with access denied for unauthorized user", %{
      conn_user: conn,
      hypervisor: hypervisor
    } do
      conn = get(conn, Routes.admin_hypervisor_path(conn, :edit, hypervisor))
      assert html_response(conn, 403)
    end
  end

  describe "update hypervisor" do
    setup [:create_hypervisor]

    test "redirects when data is valid", %{conn: conn, hypervisor: hypervisor} do
      conn =
        put(conn, Routes.admin_hypervisor_path(conn, :update, hypervisor),
          hypervisor: @update_attrs
        )

      assert redirected_to(conn) == Routes.admin_hypervisor_path(conn, :show, hypervisor)

      conn = get(conn, Routes.admin_hypervisor_path(conn, :show, hypervisor))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, hypervisor: hypervisor} do
      conn =
        put(conn, Routes.admin_hypervisor_path(conn, :update, hypervisor),
          hypervisor: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit"
    end

    test "responses with access denied for unauthorized user", %{
      conn_user: conn,
      hypervisor: hypervisor
    } do
      conn =
        put(conn, Routes.admin_hypervisor_path(conn, :update, hypervisor),
          hypervisor: @update_attrs
        )

      assert html_response(conn, 403)
    end
  end

  #
  #  describe "delete hypervisor" do
  #    setup [:create_hypervisor]
  #
  #    test "deletes chosen hypervisor", %{conn: conn, hypervisor: hypervisor} do
  #      conn = delete(conn, Routes.admin_hypervisor_path(conn, :delete, hypervisor))
  #      assert redirected_to(conn) == Routes.admin_hypervisor_path(conn, :index)
  #      assert_error_sent 404, fn ->
  #        get(conn, Routes.admin_hypervisor_path(conn, :show, hypervisor))
  #      end
  #    end
  #  end
  #

  defp prepare_struct(struct \\ @create_attrs) do
    hypervisor_type = fixture_hypervisor_type(%{name: "bhyve"})

    # Update hypervisor_type id with correct one.
    _hypervisor =
      struct
      |> Map.put(:hypervisor_type_id, hypervisor_type.id)
  end

  defp create_hypervisor(_) do
    hypervisor = prepare_struct()
    hypervisor = fixture_hypervisor(hypervisor)
    {:ok, hypervisor: hypervisor}
  end
end
