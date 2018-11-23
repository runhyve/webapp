defmodule WebappWeb.TeamNamespace do
  import Plug.Conn
  import Phoenix.Controller

  alias WebappWeb.Router.Helpers, as: Routes
  alias Webapp.{Accounts, Accounts.Team}
  alias Plug.Conn

  @restricted_namespaces ~w(dev admin hypervisors machines plans users user teams sessions)

  def init(opts), do: opts

  @doc """
  Sets a team-wide namespace based on url prefix.
  """
  def call(%Plug.Conn{} = conn, _opts) do
    conn
   # |> assign(:namespace, nil)
#    case conn.path_info do
#      [name | rest] when name not in @restricted_namespaces ->
#        case Accounts.get_namespace_by(%{"namespace" => name}) do
#          %Namespace{} = namespace ->
#            conn
#            |> assign(:namespace, namespace.namespace)
#
#          nil ->
#            assign(conn, :namespace, nil)
#        end
#
#      _ ->
#        assign(conn, :namespace, nil)
#    end
  end

  defp not_found(conn, name) do
    conn
    |> put_session(:request_path, current_path(conn))
    |> put_flash(:error, "Namespace #{name} not found!")
    |> redirect(to: Routes.page_path(conn, :index))
    |> halt()
  end
end
