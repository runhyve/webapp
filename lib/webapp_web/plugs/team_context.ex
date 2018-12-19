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
  def call(
        %Plug.Conn{assigns: %{current_user: %User{} = user, current_team: %Team{} = team}} = conn,
        _opts
      ) do
    case Enum.find(user.teams, fn user_team -> team.id == user_team.id end) do
      team ->
        member = Enum.find(user.memberships, fn membership -> membership.team_id == team.id end)

        conn
        |> assign(:current_member, member)

      nil ->
        conn
        |> put_flash(:error, "You are not authorized to view this page")
        |> redirect(to: build_path(conn.path_info))
    end
  end

  def call(%Plug.Conn{assigns: %{current_user: %User{} = user}} = conn, _opts) do
    team = Accounts.user_first_team(user)
    member = Enum.find(user.memberships, fn membership -> membership.team_id == team.id end)

    conn
    |> assign(:current_team, team)
    |> assign(:current_member, member)
  end

  def call(%Plug.Conn{} = conn, _opts) do
    conn
    |> assign(:current_team, nil)
    |> assign(:current_member, nil)
  end

  defp build_path(path_info) do
    "/" <> Enum.join(path_info, "/")
  end
end
