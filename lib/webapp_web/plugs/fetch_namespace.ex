defmodule WebappWeb.FetchNamespace do

  import Plug.Conn
  import Phoenix.Controller

  alias WebappWeb.Router.Helpers, as: Routes
  alias Webapp.{Accounts, Accounts.Namespace}
  alias Plug.Conn

  @restricted_namespaces ~w(dev admin runateam runhyve hypervisors machines plans users user groups sessions)

  def init(opts), do: opts

  @doc """
  Sets a group-wide namespace based on url prefix.
  """
  def call(%Plug.Conn{} = conn, _opts) do
    case conn.path_info do
      [name | rest] when name not in @restricted_namespaces ->
      case Accounts.get_namespace_by(%{"namespace" => name}) do
        %Namespace{} = namespace -> %{conn | path_info: rest}
                                    |> assign(:namespace, namespace)
        nil -> not_found(conn, name)
      end
      _ -> conn
    end
  end

  defp not_found(conn, name) do
    conn
    |> put_session(:request_path, current_path(conn))
    |> put_flash(:error, "Namespace #{name} not found!")
    |> redirect(to: Routes.page_path(conn, :index))
    |> halt()
  end
end