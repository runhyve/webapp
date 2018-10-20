defmodule WebappWeb.MachineController do
  use WebappWeb, :controller

  alias Webapp.Hypervisors
  alias Webapp.Hypervisors.Machine
  alias Webapp.Plans

  plug :load_references when action in [:new, :create, :edit, :update]

  def index(conn, _params) do
    machines = Hypervisors.list_machines()
    render(conn, "index.html", machines: machines)
  end

  def new(conn, _params) do
    changeset = Hypervisors.change_machine(%Machine{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"machine" => machine_params}) do
    case Hypervisors.create_machine(machine_params) do
      {:ok, machine} ->
        conn
        |> put_flash(:info, "Machine created successfully.")
        |> redirect(to: Routes.machine_path(conn, :show, machine))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    machine = Hypervisors.get_machine!(id)
    render(conn, "show.html", machine: machine)
  end

  def edit(conn, %{"id" => id}) do
    machine = Hypervisors.get_machine!(id)
    changeset = Hypervisors.change_machine(machine)
    render(conn, "edit.html", machine: machine, changeset: changeset)
  end

  def update(conn, %{"id" => id, "machine" => machine_params}) do
    machine = Hypervisors.get_machine!(id)

    case Hypervisors.update_machine(machine, machine_params) do
      {:ok, machine} ->
        conn
        |> put_flash(:info, "Machine updated successfully.")
        |> redirect(to: Routes.machine_path(conn, :show, machine))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", machine: machine, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    machine = Hypervisors.get_machine!(id)
    {:ok, _machine} = Hypervisors.delete_machine(machine)

    conn
    |> put_flash(:info, "Machine deleted successfully.")
    |> redirect(to: Routes.machine_path(conn, :index))
  end

  defp load_references(conn, _) do
    conn
    |> assign(:hypervisors, Hypervisors.list_hypervisor())
    |> assign(:plans, Plans.list_plans())
  end
end
