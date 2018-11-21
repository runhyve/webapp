defmodule WebappWeb.HandleNamespace do

  import Plug.Conn
  import Phoenix.Controller

  alias WebappWeb.Router.Helpers, as: Routes
  alias Webapp.{Accounts, Accounts.Namespace, Accounts.User}
  alias Plug.Conn

  def init(opts), do: opts

  @doc """
  When namespace is not set try to fetch it form current user.
  """
  def call(%Plug.Conn{assigns: %{namespace: %Namespace{}}} = conn, _opts), do: conn

  def call(%Plug.Conn{assigns: %{current_user: %User{namespace: %Namespace{} = namespace}}} = conn, _opts) do
    conn
    |> assign(:namespace, namespace)
  end

  def call(%Plug.Conn{} = conn, _opts) do
    conn
    |> assign(:namespace, nil)
  end

end