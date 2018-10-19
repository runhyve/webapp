defmodule WebappWeb.TypeController do
  use WebappWeb, :controller

  alias Webapp.Hypervisors
  alias Webapp.Hypervisors.Type

  def index(conn, _params) do
    hypervisor_types = Hypervisors.list_hypervisor_types()
    render(conn, "index.html", hypervisor_types: hypervisor_types)
  end

  def new(conn, _params) do
    changeset = Hypervisors.change_type(%Type{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"type" => type_params}) do
    case Hypervisors.create_type(type_params) do
      {:ok, type} ->
        conn
        |> put_flash(:info, "Type created successfully.")
        |> redirect(to: Routes.type_path(conn, :show, type))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    type = Hypervisors.get_type!(id)
    render(conn, "show.html", type: type)
  end

  def edit(conn, %{"id" => id}) do
    type = Hypervisors.get_type!(id)
    changeset = Hypervisors.change_type(type)
    render(conn, "edit.html", type: type, changeset: changeset)
  end

  def update(conn, %{"id" => id, "type" => type_params}) do
    type = Hypervisors.get_type!(id)

    case Hypervisors.update_type(type, type_params) do
      {:ok, type} ->
        conn
        |> put_flash(:info, "Type updated successfully.")
        |> redirect(to: Routes.type_path(conn, :show, type))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", type: type, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    type = Hypervisors.get_type!(id)
    {:ok, _type} = Hypervisors.delete_type(type)

    conn
    |> put_flash(:info, "Type deleted successfully.")
    |> redirect(to: Routes.type_path(conn, :index))
  end
end
