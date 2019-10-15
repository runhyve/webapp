defmodule WebappWeb.SSHPublicKeyControllerTest do
  use WebappWeb.ConnCase

  import WebappWeb.AuthCase
  alias Webapp.Accounts

  @create_attrs %{
    ssh_public_key:
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8zjxRY3HmSJ/I6VGvuwEwrQv1hViE9bRx95qz7HR0T7MP10f+X39eKbGF82Nlju1J7u3djgWjNGYp7Yumd3bqbvu8+8Q5yqUYgF2VIDc64Vl0rK4zT6otIKerRcY2vEesZu/pRTZ7VD9dentODLHISRo4+1V+lLEqIFTteBtCxxhJc2g4GVKB2MpL7btZjtqP1X6++8qkg++wXOouNE+3lcgbu6d+SbL9skx3QTO/VwdC+U2yc8lIp2hz79FxUUGIQhV8NuPXp5/sRFGHITkFIu9dxgsqcSoSQQkyBvzd6XCXuwWpAQlmtgsjfYqQdq1/XDL+F2KqH9Vb+rD2dQLT dummy@key",
    title: "some title"
  }
  @invalid_attrs %{ssh_public_key: "invalid public key", title: "some title"}

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

  def user_fixture() do
    {:ok, user} =
      Accounts.register_user(%{
        user_email: "fred@example.com",
        user_password: "reallyHard2gue$$",
        user_name: "fred",
        team_name: "company",
        team_namespace: "company"
      })

    user
  end

  def fixture(:ssh_public_key) do
    %{team: _team, user: user} = user_fixture()
    {:ok, ssh_public_key} = Accounts.create_ssh_public_key(user, @create_attrs)
    ssh_public_key
  end

  describe "index" do
    test "lists all ssh_public_keys", %{conn: conn} do
      conn = get(conn, Routes.ssh_public_key_path(conn, :index))
      assert html_response(conn, 200) =~ "SSH Keys"
    end
  end

  describe "new ssh_public_key" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.ssh_public_key_path(conn, :new))
      assert html_response(conn, 200) =~ "Add an SSH key"
    end
  end

  describe "create ssh_public_key" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.ssh_public_key_path(conn, :create), ssh_public_key: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.ssh_public_key_path(conn, :show, id)

      conn = get(conn, Routes.ssh_public_key_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Created on"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.ssh_public_key_path(conn, :create), ssh_public_key: @invalid_attrs)
      assert html_response(conn, 200) =~ "Add an SSH key"
    end
  end

  describe "delete ssh_public_key" do
    setup [:create_ssh_public_key]

    test "deletes chosen ssh_public_key", %{conn: conn, ssh_public_key: ssh_public_key} do
      conn = delete(conn, Routes.ssh_public_key_path(conn, :delete, ssh_public_key))
      assert redirected_to(conn) == Routes.ssh_public_key_path(conn, :index)

      conn = get(conn, Routes.ssh_public_key_path(conn, :show, ssh_public_key))
      assert conn.status == 404
    end
  end

  defp create_ssh_public_key(_) do
    ssh_public_key = fixture(:ssh_public_key)
    {:ok, ssh_public_key: ssh_public_key}
  end
end
