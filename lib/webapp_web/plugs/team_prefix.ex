defmodule WebappWeb.TeamPrefix do
  import Plug.Conn

  alias Webapp.{Accounts, Accounts.Team}

  @restricted_namespaces ~w(health dev admin hypervisors machines plans users user teams sessions)

  def init(opts), do: opts

  @doc """
  Sets a team-wide namespace based on url prefix.
  """
  def call(%Plug.Conn{} = conn, _opts) do
    case conn.path_info do
      [name | rest] when name not in @restricted_namespaces ->
        case Accounts.get_team_by(%{"namespace" => name}) do
          %Team{} = team ->
            %{conn | path_info: rest}
            |> assign(:current_team, team)

          nil ->
            assign(conn, :current_team, nil)
        end

      _ ->
        assign(conn, :current_team, nil)
    end
  end
end
