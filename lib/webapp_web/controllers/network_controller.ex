defmodule WebappWeb.NetworkController do
  use WebappWeb, :controller

  alias Webapp.Hypervisors
  alias Webapp.Hypervisors.Network

  plug :load_references when action in [:new, :create, :edit, :update]
  plug :load_network when action not in [:index, :create, :new]


  def index(conn, _params) do
    networks = Hypervisors.list_networks()
    render(conn, "index.html", networks: networks)
  end

  def new(conn, _params) do
    changeset = Hypervisors.change_network(%Network{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"network" => network_params}) do
    case Hypervisors.create_network(network_params) do
      {:ok, network} ->
        conn
        |> put_flash(:info, "Network created successfully.")
        |> redirect(to: Routes.network_path(conn, :show, network))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    network = conn.assigns[:network]
    render(conn, "show.html", network: network)
  end

  def edit(conn, %{"id" => id}) do
    network = conn.assigns[:network]
    changeset = Hypervisors.change_network(network)
    render(conn, "edit.html", network: network, changeset: changeset)
  end

  def update(conn, %{"id" => id, "network" => network_params}) do
    network = Hypervisors.get_network!(id)

    case Hypervisors.update_network(network, network_params) do
      {:ok, network} ->
        conn
        |> put_flash(:info, "Network updated successfully.")
        |> redirect(to: Routes.network_path(conn, :show, network))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", network: network, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    network = conn.assigns[:network]
    {:ok, _network} = Hypervisors.delete_network(network)

    conn
    |> put_flash(:info, "Network deleted successfully.")
    |> redirect(to: Routes.network_path(conn, :index))
  end

  defp load_network(conn, _) do
    try do
      %{"id" => id} = conn.params
      network = Hypervisors.get_network!(id)

      conn
      |> assign(:network, network)
    rescue
      e ->
        conn
        |> put_flash(:error, "Network was not found.")
        |> redirect(to: Routes.network_path(conn, :index))
    end
  end


  defp load_references(conn, _) do
    conn
    |> assign(:hypervisors, Hypervisors.list_hypervisor())
  end
end
