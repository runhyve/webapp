defmodule WebappWeb.Authorize do
  @moduledoc """
  Functions to help with authorization.

  See the [Authorization wiki page](https://github.com/riverrun/phauxth/wiki/Authorization)
  for more information and examples about authorization.
  """

  import Plug.Conn
  import Phoenix.Controller

  alias WebappWeb.Router.Helpers, as: Routes

  alias Webapp.{Accounts, Accounts.User}

  @doc """
  Plug to only allow authenticated users to access the resource.
  """
  def is_logged_in(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    need_login(conn)
  end

  def is_logged_in(conn, _opts), do: conn

  @doc """
  Plug to only allow authenticated admins to access the resource.
  """
  def is_admin?(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    need_login(conn)
  end

  def is_admin?(%Plug.Conn{assigns: %{current_user: %User{role: role}}} = conn, _opts)
      when role !== "Admin" do
    unauthorized(conn)
  end

  def is_admin?(conn, _opts), do: conn

  @doc """
  Plug to only allow unauthenticated users to access the resource.

  See the session controller for an example.
  """
  def is_anonymous(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts), do: conn

  def is_anonymous(%Plug.Conn{assigns: %{current_user: _current_user}} = conn, _opts),
    do: need_logout(conn)

  @doc """
  Plug to only allow authenticated users with the correct id to access the resource.

  See the user controller for an example.
  """
  def is_current_user(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    need_login(conn)
  end

  def is_current_user(
        %Plug.Conn{params: %{"namespace" => namespace}, assigns: %{current_user: current_user}} =
          conn,
        _opts
      ) do
    user = Accounts.get_by(%{"namespace" => namespace})

    if user.id == current_user.id do
      conn
    else
      unauthorized(conn)
    end
  end

  defp need_login(conn) do
    conn
    |> put_session(:request_path, current_path(conn))
    |> put_flash(:error, "You need to log in to view this page")
    |> redirect(to: Routes.session_path(conn, :new))
    |> halt()
  end

  defp need_logout(conn) do
    conn
    |> put_flash(:error, "You need to log out to view this page")
    |> redirect(to: Routes.page_path(conn, :index))
    |> halt()
  end

  defp unauthorized(conn) do
    conn
    |> put_session(:request_path, current_path(conn))
    |> put_flash(:error, "You are not authorized to view this page")
    |> redirect(to: Routes.page_path(conn, :index))
    |> halt()
  end
end
