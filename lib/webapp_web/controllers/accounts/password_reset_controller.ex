defmodule WebappWeb.PasswordResetController do
  use WebappWeb, :controller

  alias Phauxth.Confirm.PassReset
  alias Webapp.{Accounts, Accounts.User}
  alias WebappWeb.{Auth.Token}
  alias WebappWeb.Emails.UserEmail, as: Email

  def new(%Plug.Conn{assigns: %{current_user: %User{} = _user}} = conn, _params) do
    render(conn, "change.html")
  end

  def new(conn, _params) do
    render(conn, "reset.html")
  end

  def create(conn, %{"password_reset" => %{"email" => ""}}) do
    conn
    |> put_flash(:error, "Enter email address.")
    |> redirect(to: Routes.password_reset_path(conn, :new))
  end

  def create(conn, %{"password_reset" => %{"email" => email}}) do
    if Accounts.create_password_reset(%{"email" => email}) do
      key = Token.sign(%{"email" => email})
      Email.reset_request(email, key)
    end

    conn
    |> put_flash(:info, "Check your inbox for instructions on how to reset your password")
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def edit(conn, %{"key" => key}) do
    render(conn, "edit.html", key: key)
  end

  def edit(conn, _params) do
    render(conn, WebappWeb.ErrorView, "404.html")
  end

  def update(conn, %{"password_reset" => params}) do
    case PassReset.verify(params, []) do
      {:ok, user} ->
        user
        |> Accounts.update_password(params)
        |> update_password(conn, params)

      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> render("edit.html", key: params["key"])
    end
  end

  defp update_password({:ok, user}, conn, _params) do
    Email.reset_success(user.email)

    conn
    |> delete_session(:phauxth_session_id)
    |> put_flash(:info, "Your password has been reset")
    |> redirect(to: Routes.session_path(conn, :new))
  end

  defp update_password({:error, %Ecto.Changeset{} = changeset}, conn, params) do
    message = with p <- changeset.errors[:password], do: elem(p, 0)

    conn
    |> put_flash(:error, message || "Invalid input")
    |> render("edit.html", key: params["key"])
  end
end
