defmodule WebappWeb.UserControllerTest do
  use WebappWeb.ConnCase

  import WebappWeb.AuthCase
  alias Webapp.Accounts

  @valid_user %{
    user_email: "bill@example.com",
    user_password: "hard2guess",
    user_name: "bill",
    team_name: "bill Team",
    team_namespace: "bill-team"
  }
  @update_attrs %{email: "william@example.com"}
  @invalid_user %{email: nil}

  setup %{conn: conn} = config do
    conn = conn |> bypass_through(WebappWeb.Router, [:browser]) |> get("/")

    if email = config[:login] do
      user = add_user(email)
      other = add_user("tony@example.com")
      conn = conn |> add_session(user) |> send_resp(:ok, "/")
      {:ok, %{conn: conn, user: user, other: other}}
    else
      {:ok, %{conn: conn}}
    end
  end

  describe "index" do
    @tag login: "reg@example.com"
    test "lists all entries on index", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert html_response(conn, 403)
    end

    test "renders /users error for unauthorized user", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert html_response(conn, 403)
    end
  end

  describe "renders forms" do
    test "renders form for new users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      assert html_response(conn, 200) =~ "New User"
    end

    @tag login: "reg@example.com"
    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit Profile"
    end
  end

  describe "show user resource" do
    @tag login: "reg@example.com"
    test "show chosen user's page", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "Change password"
    end
  end

  describe "create user" do
    test "creates user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), registration: @valid_user)
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end

    test "does not create user and renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), registration: @invalid_user)
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "updates user" do
    @tag login: "reg@example.com"
    test "updates chosen user when data is valid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      updated_user = Accounts.get_user(user.id)
      assert updated_user.email == "william@example.com"
      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "william@example.com"
    end

    @tag login: "reg@example.com"
    test "does not update chosen user and renders errors when data is invalid", %{
      conn: conn,
      user: user
    } do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_user)
      assert html_response(conn, 200) =~ "Edit Profile"
    end
  end

  #  describe "delete user" do
  #    @tag login: "reg@example.com"
  #    test "deletes chosen user", %{conn: conn, user: user} do
  #      conn = delete(conn, Routes.user_path(conn, :delete, user))
  #      assert redirected_to(conn) == Routes.session_path(conn, :new)
  #      refute Accounts.get_user(user.id)
  #    end
  #
  #    @tag login: "reg@example.com"
  #    test "cannot delete other user", %{conn: conn, user: user, other: other} do
  #      conn = delete(conn, Routes.user_path(conn, :delete, other))
  #      assert redirected_to(conn) == Routes.page_path(conn, :index)
  #      assert Accounts.get_user(other.id)
  #    end
  #  end
end
