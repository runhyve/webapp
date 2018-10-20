defmodule WebappWeb.HypervisorController do
  use WebappWeb, :controller

  alias Webapp.Hypervisors
  alias Webapp.Hypervisors.Hypervisor

  plug :load_hypervisor_types when action in [:new, :create, :edit, :update]

  def index(conn, _params) do
    hypervisor = Hypervisors.list_hypervisor()
    render(conn, "index.html", hypervisor: hypervisor)
  end

  def new(conn, _params) do
    changeset = Hypervisors.change_hypervisor(%Hypervisor{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"hypervisor" => hypervisor_params}) do
    case Hypervisors.create_hypervisor(hypervisor_params) do
      {:ok, hypervisor} ->
        conn
        |> put_flash(:info, "Hypervisor created successfully.")
        |> redirect(to: Routes.hypervisor_path(conn, :show, hypervisor))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    hypervisor = Hypervisors.get_hypervisor!(id)
    render(conn, "show.html", hypervisor: hypervisor)
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
    hypervisor = Hypervisors.get_hypervisor!(id)
    {:ok, _hypervisor} = Hypervisors.delete_hypervisor(hypervisor)

    conn
    |> put_flash(:info, "Hypervisor deleted successfully.")
    |> redirect(to: Routes.hypervisor_path(conn, :index))
  end

  defp load_hypervisor_types(conn, _) do
    conn
    |> assign(:hypervisor_types, Hypervisors.list_hypervisor_types())
  end
end