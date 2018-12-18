defmodule WebappWeb.UserController do
  use WebappWeb, :controller

  alias Phauxth.{Log, Confirm}
  alias Webapp.{Accounts, Accounts.User, Accounts.Registration}
  alias WebappWeb.{Auth.Token}
  alias WebappWeb.Emails.UserEmail, as: Email
  alias Ecto.Changeset

  plug :authorize_resource,
       model: User,
       non_id_actions: [:index, :create, :new, :confirm]

  def new(conn, _) do
    changeset = Accounts.change_registration(%Registration{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"registration" => registration_params}) do
    changeset = Registration.changeset(%Registration{}, registration_params)

    case Accounts.register_user(registration_params) do
      {:ok, %{user: user}} ->
        key = Token.sign(%{"email" => user.email})
        Log.info(%Log{user: user.id, message: "user created"})
        Email.confirm_request(user.email, key)

        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.session_path(conn, :new))

      {:error, :registration, multi_changeset, _changes} ->
        changeset = %{changeset | errors: multi_changeset.errors, valid?: false, action: :insert}
        render(conn, "new.html", changeset: changeset)

      {:error, :user, multi_changeset, _changes} ->
        changeset = Registration.copy_changeset_errors(multi_changeset, changeset, "user")
        render(conn, "new.html", changeset: %{changeset | action: :insert})

      {:error, :team, multi_changeset, _changes} ->
        changeset = Registration.copy_changeset_errors(multi_changeset, changeset, "team")
        render(conn, "new.html", changeset: %{changeset | action: :insert})
    end
  end

  def confirm(conn, params) do
    case Confirm.verify(params) do
      {:ok, user} ->
        Accounts.confirm_user(user)
        Email.confirm_success(user.email)

        conn
        |> put_flash(:info, "Your account has been confirmed")
        |> redirect(to: Routes.session_path(conn, :new))

      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: Routes.session_path(conn, :new))
    end
  end

  def show(%Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    Accounts.get_by(%{"user_id" => id})
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

  def teams(%Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    user = Accounts.get_by(%{"user_id" => id}, [:teams])

    conn
    |> put_view(WebappWeb.TeamView)
    |> render("index.html", teams: user.teams, user: user)
  end
end
