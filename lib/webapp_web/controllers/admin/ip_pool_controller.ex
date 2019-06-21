defmodule WebappWeb.Admin.Ip_poolController do
  use WebappWeb, :controller

  alias Webapp.{
    Hypervisors,
    Networks,
    Networks.Ip_pool,
    Networks.Ipv4
  }

  plug :load_and_authorize_resource,
    model: Ip_pool,
    non_id_actions: [:index, :create, :new],
    preload: [:network, ipv4: {Ipv4.preload_ordered, :machine}]

  def index(conn, _params) do
    ip_pools = Networks.list_ip_pools([:network, :ipv4])
    render(conn, "index.html", ip_pools: ip_pools)
  end

  def new(conn, _params) do
    networks = Networks.list_networks([:hypervisor])

    changeset = Networks.change_ip_pool(%Ip_pool{})
    render(conn, "new.html", changeset: changeset, networks: networks)
  end

  def create(conn, %{"ip_pool" => ip_pool_params}) do
    networks = Networks.list_networks([:hypervisor])

    case Networks.create_ip_pool(ip_pool_params) do
      {:ok, %{ip_pool: ip_pool}} ->
        conn
        |> put_flash(:info, "Ip pool created successfully.")
        |> redirect(to: Routes.admin_ip_pool_path(conn, :show, ip_pool))

      {:error, :ip_pool, %Ecto.Changeset{} = changeset, _} ->
        render(conn, "new.html", changeset: changeset, networks: networks)
    end
  end

  def show(conn, _params) do
    ip_pool = conn.assigns[:ip_pool]
    render(conn, "show.html", ip_pool: ip_pool)
  end
end
