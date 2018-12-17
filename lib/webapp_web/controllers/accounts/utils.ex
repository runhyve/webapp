defmodule WebappWeb.Accounts.Utils do
  use WebappWeb, :controller

  @moduledoc """
  Helper functions for authentication.
  """

  alias Webapp.{
    Sessions
  }

  @doc """
  Adds session data to the database.
  This function is used by Phauxth.Remember.
  """
  def create_session(%Plug.Conn{assigns: %{current_user: %{id: user_id}}}) do
    Sessions.create_session(%{user_id: user_id})
  end

  def handle_unauthorized(conn) do
    conn
    |> put_flash(:error, "You can't access that page!")
    |> put_view(WebappWeb.PageView)
    |> render("access_denied.html")
    |> halt
  end

  def handle_not_found(conn) do
    conn
    |> put_flash(:error, "Not found!")
    |> put_view(WebappWeb.PageView)
    |> render("not_found.html")
    |> halt
  end
end