defmodule WebappWeb.HypervisorController do
  use WebappWeb, :controller

  alias Webapp.Hypervisors
  alias Webapp.Hypervisors.Hypervisor

  plug :load_hypervisor_types when action in [:new, :create, :edit, :update]
  plug :load_hypervisor when action not in [:index, :create, :new]

  def index(conn, _params) do
    hypervisor = Hypervisors.list_hypervisor()
    render(conn, "index.html", hypervisor: hypervisor)
  end

  def index_networks(conn, _params) do
    hypervisor = conn.assigns[:hypervisor]
    networks = Hypervisors.list_hypervisor_networks(hypervisor)
    render(conn, "networks.html", networks: networks, hypervisor: hypervisor)
  end

  def new(conn, _params) do
    changeset = Hypervisors.change_hypervisor(%Hypervisor{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"hypervisor" => hypervisor_params}) do
    case Hypervisors.create_hypervisor(hypervisor_params) do
      {:ok, %{hypervisor: hypervisor}} ->
        conn
        |> put_flash(:info, "Hypervisor created successfully.")
        |> redirect(to: Routes.hypervisor_path(conn, :show, hypervisor))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)

      {:error, :hypervisor, %Ecto.Changeset{} = changeset, _} ->
        render(conn, "new.html", changeset: changeset)

      {:error, :network, _network_changeset, _} ->
        changeset =
          %Hypervisor{}
          |> Hypervisor.changeset(hypervisor_params)

        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    hypervisor = conn.assigns[:hypervisor]

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

    render(conn, "show.html", hypervisor: hypervisor, status: status)
  end

  def edit(conn, %{"id" => id}) do
    hypervisor = Hypervisors.get_hypervisor!(id)
    changeset = Hypervisors.change_hypervisor(hypervisor)
    render(conn, "edit.html", hypervisor: hypervisor, changeset: changeset)
  end

  def update(conn, %{"id" => id, "hypervisor" => hypervisor_params}) do
    hypervisor = Hypervisors.get_hypervisor!(id)

    case Hypervisors.update_hypervisor(hypervisor, hypervisor_params) do
      {:ok, hypervisor} ->
        conn
        |> put_flash(:info, "Hypervisor updated successfully.")
        |> redirect(to: Routes.hypervisor_path(conn, :show, hypervisor))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", hypervisor: hypervisor, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    hypervisor = Hypervisors.get_hypervisor_with_machines!(id)

    case Enum.count(hypervisor.machines) do
      0 ->
        {:ok, _hypervisor} = Hypervisors.delete_hypervisor(hypervisor)

        conn
        |> put_flash(:info, "Hypervisor deleted successfully.")
        |> redirect(to: Routes.hypervisor_path(conn, :index))

      _ ->
        conn
        |> put_flash(:error, "Hypervisor can not be deleted. First, remove all related machines.")
        |> redirect(to: Routes.hypervisor_path(conn, :show, hypervisor))
    end
  end

  defp load_hypervisor(conn, _) do
    try do
      %{"id" => id} = conn.params
      hypervisor = Hypervisors.get_hypervisor!(id)

      conn
      |> assign(:hypervisor, hypervisor)
    rescue
      e ->
        conn
        |> put_flash(:error, "Hypervisor was not found.")
        |> redirect(to: Routes.hypervisor_path(conn, :index))
    end
  end

  defp load_hypervisor_types(conn, _) do
    conn
    |> assign(:hypervisor_types, Hypervisors.list_hypervisor_types())
  end
end
