defmodule WebappWeb.TeamContext do
  import Plug.Conn
  import Phoenix.Controller

  alias WebappWeb.Router.Helpers, as: Routes
  alias Webapp.{Accounts, Accounts.Team, Accounts.User}
  alias Plug.Conn

  def init(opts), do: opts

  @doc """
  Set user namespace if there is no team namespace, based on current user.
  """
  def call(%Plug.Conn{assigns: %{team: %Team{} = team}} = conn, _opts), do: conn

  def call(%Plug.Conn{assigns: %{current_user: %User{} = user}} = conn, _opts) do
    team = Accounts.user_first_team(user)

    conn
    |> assign(:team, team)
  end

  def call(%Plug.Conn{} = conn, _opts) do
    conn
    |> assign(:team, nil)
  end
end
