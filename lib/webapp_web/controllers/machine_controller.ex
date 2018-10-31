defmodule WebappWeb.MachineController do
  use WebappWeb, :controller

  alias Webapp.Hypervisors
  alias Webapp.Hypervisors.Machine
  alias Webapp.Plans

  plug :load_references when action in [:new, :create, :edit, :update]
  plug :load_machine when action not in [:index, :create, :new]

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
      {:ok, %{machine: machine}} ->
        conn
        |> put_flash(:info, "Machine created successfully.")
        |> redirect(to: Routes.machine_path(conn, :show, machine))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)

      {:error, :machine, %Ecto.Changeset{} = changeset, _} ->
        render(conn, "new.html", changeset: changeset)

      {:error, :hypervisor, error, _} ->
        changeset =
          %Machine{}
          |> Machine.changeset(machine_params)

        conn
        |> put_flash(:error, error)
        |> render("new.html", changeset: changeset)

      {:error, :hypervisor_not_found, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Machine was not created successfully.")
        |> render("new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    machine = conn.assigns[:machine]

    case Hypervisors.check_status(machine) do
      {:ok, %Machine{} = machine} ->
        conn
        |> render("show.html", machine: machine)

      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> render("show.html", machine: machine)
    end
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
    machine = conn.assigns[:machine]

    case Hypervisors.delete_machine(machine) do
      {:ok, _machine} ->
        conn
        |> put_flash(:info, "Machine deleted successfully.")
        |> redirect(to: Routes.machine_path(conn, :index))

      {:error, :hypervisor, error, changes} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: Routes.machine_path(conn, :index))

      {:error, :hypervisor_not_found, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Machine was not deleted successfully.")
        |> redirect(to: Routes.machine_path(conn, :index))
    end
  end

  def start(conn, %{"id" => id}) do
    machine = conn.assigns[:machine]

    case Hypervisors.start_machine(machine) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Machine is starting")
        |> redirect(to: Routes.machine_path(conn, :show, machine))

      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: Routes.machine_path(conn, :show, machine))
    end
  end

  def stop(conn, %{"id" => id}) do
    machine = conn.assigns[:machine]

    case Hypervisors.stop_machine(machine) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Machine is stopping")
        |> redirect(to: Routes.machine_path(conn, :show, machine))

      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: Routes.machine_path(conn, :show, machine))
    end
  end

  def poweroff(conn, %{"id" => id}) do
    machine = Hypervisors.get_machine!(id)

    case Hypervisors.poweroff_machine(machine) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Machine is being powered off")
        |> redirect(to: Routes.machine_path(conn, :show, machine))

      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: Routes.machine_path(conn, :show, machine))
    end
  end

  def console(conn, %{"id" => id}) do
    machine = conn.assigns[:machine]

    with {:ok, console} <- Hypervisors.console_machine(machine) do
      token = Base.encode64(console["user"] <> ":" <> console["password"])
      render(conn, "console.html", machine: machine, console: console, token: token)
    else
      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: Routes.machine_path(conn, :show, machine))
    end
  end

  defp load_machine(conn, _) do
    try do
      %{"id" => id} = conn.params
      machine = Hypervisors.get_machine!(id)

      conn
      |> assign(:machine, machine)
    rescue
      e ->
        conn
        |> put_flash(:error, "Machine was not found.")
        |> redirect(to: Routes.machine_path(conn, :index))
    end
  end

  defp load_references(conn, _) do
    conn
    |> assign(:hypervisors, Hypervisors.list_hypervisor())
    |> assign(:plans, Plans.list_plans())
  end
end
