defmodule WebappWeb.DefaultNamespace do
  import Plug.Conn
  import Phoenix.Controller

  alias WebappWeb.Router.Helpers, as: Routes
  alias Webapp.{Accounts, Accounts.Team, Accounts.User}
  alias Plug.Conn

  def init(opts), do: opts

  @doc """
  Set user namespace if there is no team namespace, based on current user.
  """
  def call(%Plug.Conn{assigns: %{namespace: _namespace}} = conn, _opts), do: conn

  def call(%Plug.Conn{assigns: %{current_user: %User{} = user}} = conn, _opts) do
    team = Accounts.user_first_team(user)

    conn
    |> assign(:namespace, team.name)
  end

  def call(%Plug.Conn{} = conn, _opts) do
    conn
    |> assign(:namespace, nil)
  end
end
