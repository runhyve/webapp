defmodule WebappWeb.HypervisorTokenAuth do
    @type ok_or_error :: {:ok, map} | {:error, String.t() | atom}
    @callback authenticate(Plug.Conn.t(), module, keyword) :: ok_or_error
    @callback report(ok_or_error, keyword) :: map | nil

    @behaviour Plug
    alias Webapp.{Repo, Hypervisors, Hypervisors.Hypervisor}
    import Plug.Conn
    import Logger

    @impl Plug
    def init(opts) do
      {Keyword.get(opts, :log_meta, []), opts}
    end
    
    @impl Plug
    def call(conn, {log_meta, opts}) do
      conn
      |> authenticate(opts)
      |> report(log_meta)
      |> set_hypervisor(conn)
    end

    @impl WebappWeb.HypervisorTokenAuth
    def authenticate(conn, opts) do
        conn
        |> get_req_header("token")
        |> verify_hypervisor_token(opts)
    end

    defp verify_hypervisor_token([token], opts) do
        case Hypervisors.get_hypervisor_by("webhook_token", token) do
            nil -> {:error, "authentication failed"}
            hypervisor -> {:ok, hypervisor}
        end
    end

    defp verify_hypervisor_token([], _) do
        {:error, "authentication token missing"}
    end

    def report({:ok, hypervisor}, meta) do
        Logger.info("hypervisor #{hypervisor.name} authenticated")
        hypervisor
    end

    def report({:error, message}, meta) do
        Logger.info(message)
        nil
    end

    @impl WebappWeb.HypervisorTokenAuth
    def set_hypervisor(hypervisor, conn) do 
        case hypervisor do
            nil -> send_resp(conn, 401, "Unathorized") |> halt
            _ -> assign(conn, :hypervisor, hypervisor) 
        end
    end

    defoverridable Plug
end