defmodule WebappWeb.Admin.RegionController do
  use WebappWeb, :controller

  alias Webapp.Regions
  alias Webapp.Regions.Region


  plug :load_and_authorize_resource,
    model: Region,
    non_id_actions: [:index, :create, :new]

  def index(conn, _params) do
    regions = Regions.list_regions()
    render(conn, "index.html", regions: regions)
  end

  def new(conn, _params) do
    changeset = Regions.change_region(%Region{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"region" => region_params}) do
    case Regions.create_region(region_params) do
      {:ok, region} ->
        conn
        |> put_flash(:info, "Region created successfully.")
        |> redirect(to: Routes.admin_region_path(conn, :show, region))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    region = Regions.get_region!(id, [:hypervisors])
    render(conn, "show.html", region: region)
  end

  def edit(conn, %{"id" => id}) do
    region = Regions.get_region!(id)
    changeset = Regions.change_region(region)
    render(conn, "edit.html", region: region, changeset: changeset)
  end

  def update(conn, %{"id" => id, "region" => region_params}) do
    region = Regions.get_region!(id)

    case Regions.update_region(region, region_params) do
      {:ok, region} ->
        conn
        |> put_flash(:info, "Region updated successfully.")
        |> redirect(to: Routes.admin_region_path(conn, :show, region))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", region: region, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    region = Regions.get_region!(id, [:hypervisors])

    IO.inspect region
    case Enum.count(region.hypervisors) do
      0 ->
        {:ok, _region} = Regions.delete_region(region)

        conn
        |> put_flash(:info, "Region deleted successfully.")
        |> redirect(to: Routes.admin_region_path(conn, :index))
      _ ->
        conn
        |> put_flash(:error, "Can't remove this region because it has assigned hypervisors")
        |> redirect(to: Routes.admin_region_path(conn, :show, region))
    end
  end
end
