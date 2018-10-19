defmodule WebappWeb.BhyveController do
  use WebappWeb, :controller

  alias Webapp.Hypervisors
  alias Webapp.Hypervisors.Bhyve

  def index(conn, _params) do
    hv_bhyve = Hypervisors.list_hv_bhyve()
    render(conn, "index.html", hv_bhyve: hv_bhyve)
  end

  def new(conn, _params) do
    changeset = Hypervisors.change_bhyve(%Bhyve{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"bhyve" => bhyve_params}) do
    case Hypervisors.create_bhyve(bhyve_params) do
      {:ok, bhyve} ->
        conn
        |> put_flash(:info, "Bhyve created successfully.")
        |> redirect(to: Routes.bhyve_path(conn, :show, bhyve))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    bhyve = Hypervisors.get_bhyve!(id)
    render(conn, "show.html", bhyve: bhyve)
  end

  def edit(conn, %{"id" => id}) do
    bhyve = Hypervisors.get_bhyve!(id)
    changeset = Hypervisors.change_bhyve(bhyve)
    render(conn, "edit.html", bhyve: bhyve, changeset: changeset)
  end

  def update(conn, %{"id" => id, "bhyve" => bhyve_params}) do
    bhyve = Hypervisors.get_bhyve!(id)

    case Hypervisors.update_bhyve(bhyve, bhyve_params) do
      {:ok, bhyve} ->
        conn
        |> put_flash(:info, "Bhyve updated successfully.")
        |> redirect(to: Routes.bhyve_path(conn, :show, bhyve))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", bhyve: bhyve, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    bhyve = Hypervisors.get_bhyve!(id)
    {:ok, _bhyve} = Hypervisors.delete_bhyve(bhyve)

    conn
    |> put_flash(:info, "Bhyve deleted successfully.")
    |> redirect(to: Routes.bhyve_path(conn, :index))
  end
end
