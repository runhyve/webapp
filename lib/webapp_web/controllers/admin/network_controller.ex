defmodule WebappWeb.Admin.NetworkController do
  use WebappWeb, :controller

  alias Webapp.{
    Hypervisors,
    Networks,
    Networks.Network
  }

  plug :load_hypervisor when action in [:index, :create, :new]
  plug :load_network when action not in [:index, :create, :new]

  plug :load_and_authorize_resource,
    model: Network,
    non_id_actions: [:index, :create, :new],
    preload: []

  def index(conn, _params) do
    hypervisor = conn.assigns[:hypervisor]

    # @TODO: Refactor this
    status =
      case Hypervisors.update_hypervisor_status(hypervisor) do
        {:ok, status} -> status
        {:error, _} -> "unreachable"
      end

    conn =
      if status == "unreachable" do
        put_flash(conn, :error, "Failed to fetch hypervisor status")
      else
        conn
      end

    networks = Hypervisors.list_hypervisor_networks(hypervisor)
    render(conn, "index.html", networks: networks, hypervisor: hypervisor, status: status)
  end

  def new(conn, _params) do
    hypervisor = conn.assigns[:hypervisor]
    changeset = Networks.change_network(%Network{hypervisor_id: hypervisor.id})

    render(conn, "new.html", changeset: changeset, hypervisor: hypervisor)
  end

  def create(conn, %{"network" => network_params}) do
    case Networks.create_network(network_params) do
      {:ok, %{network: network}} ->
        conn
        |> put_flash(:info, "Network created successfully.")
        |> redirect(to: Routes.admin_network_path(conn, :show, network))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)

      {:error, :machine, %Ecto.Changeset{} = changeset, _} ->
        render(conn, "new.html", changeset: changeset)

      {:error, :hypervisor, error, _} ->
        changeset =
          %Network{}
          |> Network.changeset(network_params)

        conn
        |> put_flash(:error, error)
        |> render("new.html", changeset: changeset)

      {:error, :hypervisor_not_found} ->
        changeset =
          %Network{}
          |> Network.changeset(network_params)

        conn
        |> put_flash(:error, "Network was not created successfully.")
        |> render("new.html", changeset: changeset)
    end
  end

  def show(conn, _params) do
    network = conn.assigns[:network]
    render(conn, "show.html", network: network, hypervisor: network.hypervisor)
  end

  def edit(conn, _params) do
    network = conn.assigns[:network]
    changeset = Networks.change_network(network)

    render(conn, "edit.html",
      network: network,
      changeset: changeset,
      hypervisor: network.hypervisor
    )
  end

  def update(conn, %{"id" => id, "network" => network_params}) do
    network = Networks.get_network!(id)

    case Networks.update_network(network, network_params) do
      {:ok, network} ->
        conn
        |> put_flash(:info, "Network updated successfully.")
        |> redirect(to: Routes.admin_network_path(conn, :show, network))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", network: network, changeset: changeset)
    end
  end

  def delete(conn, _params) do
    network = conn.assigns[:network]
    hypervisor = network.hypervisor

    {:ok, _network} = Networks.delete_network(network)

    conn
    |> put_flash(:info, "Network deleted successfully.")
    |> redirect(to: Routes.admin_hypervisor_network_path(conn, :index, hypervisor))
  end

  defp load_network(conn, _) do
    try do
      %{"id" => id} = conn.params
      network = Networks.get_network!(id)

      conn
      |> assign(:network, network)
    rescue
      _ ->
        conn
        |> put_flash(:error, "Network was not found.")
        |> redirect(to: Routes.admin_hypervisor_path(conn, :index))
    end
  end

  def load_hypervisor(conn, _) do
    try do
      %{"hypervisor_id" => id} = conn.params
      hypervisor = Hypervisors.get_hypervisor!(id)

      conn
      |> assign(:hypervisor, hypervisor)
    rescue
      _ ->
        conn
        |> put_flash(:error, "Hypervisor was not found.")
        |> redirect(to: Routes.admin_hypervisor_path(conn, :index))
    end
  end
end
