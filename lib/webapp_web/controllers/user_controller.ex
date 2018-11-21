defmodule WebappWeb.UserController do
  use WebappWeb, :controller

  alias Phauxth.Log
  alias Webapp.{Accounts, Accounts.User, Accounts.Namespace}
  alias WebappWeb.{Auth.Token}
  alias WebappWeb.Emails.UserEmail, as: Email

  # the following plugs are defined in the controllers/authorize.ex file
  plug :is_logged_in when action in [:index, :show]
  plug :is_current_user when action in [:edit, :update, :delete]

  #plug :load_resource, model: User,


  def index(conn, _) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _) do
    changeset = Accounts.change_user(%User{namespace: %Namespace{}})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => %{"email" => email} = user_params}) do
    key = Token.sign(%{"email" => email})

    case Accounts.create_user(user_params) do
      {:ok, user} ->
        Log.info(%Log{user: user.id, message: "user created"})

        Email.confirm_request(email, key)

        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.session_path(conn, :new))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(%Conn{assigns: %{current_user: user}} = conn, %{"namespace" => namespace}) do
    Accounts.get_by(%{"namespace" => namespace})
    render(conn, "show.html", user: user)
  end

  def edit(%Conn{assigns: %{current_user: user}} = conn, _) do
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(%Conn{assigns: %{current_user: user}} = conn, %{"user" => user_params}) do
    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(%Conn{assigns: %{current_user: user}} = conn, _) do
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> delete_session(:phauxth_session_id)
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.session_path(conn, :new))
  end
end
