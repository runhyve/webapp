defmodule WebappWeb.MachineController do
  use WebappWeb, :controller

  alias Webapp.{
    Machines,
    Machines.Machine,
    Hypervisors,
    Networks,
    Plans
  }

  plug :load_machine when action not in [:index, :create, :new]
  plug :load_hypervisor when action in [:new, :create]
  plug :load_references when action in [:new, :create, :edit, :update]

  def index(conn, %{"hypervisor_id" => hypervisor_id} = params) do
    conn = load_hypervisor(conn, params)
    hypervisor = conn.assigns[:hypervisor]
    machines = Hypervisors.list_hypervisor_machines(hypervisor, [:hypervisor, :plan, :networks])

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

    render(conn, "index.html", machines: machines, hypervisor: hypervisor, status: status)
  end

  def index(conn, _params) do
    machines = Machines.list_machines([:hypervisor, :plan, :networks])
    render(conn, "index.html", machines: machines, hypervisor: false)
  end

  def new(conn, _params) do
    changeset = Machines.change_machine(%Machine{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"machine" => machine_params}) do
    case Machines.create_machine(machine_params) do
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

  def show(conn, _params) do
    machine = conn.assigns[:machine]

    case Machines.check_status(machine) do
      {:ok, %Machine{} = machine} ->
        conn
        |> render("show.html", machine: machine)

      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> render("show.html", machine: machine)
    end
  end

  def edit(conn, _params) do
    machine = conn.assigns[:machine]
    changeset = Machines.change_machine(machine)

    render(conn, "settings.html", machine: machine, changeset: changeset)
  end

  # Add network
  def update(conn, %{"machine" => %{"network_ids" => network_id}}) do
    machine = conn.assigns[:machine]
    network = Networks.get_network!(network_id)

    case Machines.add_network_to_machine(machine, network) do
      {:ok, %{machine: machine}} ->
        conn
        |> put_flash(:info, "Network added to Machine successfully.")
        |> redirect(to: Routes.machine_path(conn, :show, machine))

      # Errors from changeset should be displayed!
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Network was not added to Machine successfully.")
        |> redirect(to: Routes.machine_path(conn, :show, machine))

      # Errors from changeset should be displayed!
      {:error, :machine, %Ecto.Changeset{} = changeset, _} ->
        conn
        |> put_flash(:error, "Network was not added to Machine successfully.")
        |> redirect(to: Routes.machine_path(conn, :show, machine))

      {:error, :hypervisor, error, _} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: Routes.machine_path(conn, :show, machine))

      {:error, :hypervisor_not_found} ->
        conn
        |> put_flash(:error, "Machine was not created successfully.")
        |> redirect(to: Routes.machine_path(conn, :show, machine))
    end
  end

  # Change machine name
  def update(conn, %{"id" => id, "machine" => %{"name" => name} = machine_params}) do
    machine = Machines.get_machine!(id, [:networks])

    conn
    |> put_flash(:error, "Not implemented yet.")
    |> redirect(to: Routes.machine_path(conn, :show, machine))
  end

  def delete(conn, _params) do
    machine = conn.assigns[:machine]

    case Machines.delete_machine(machine) do
      {:ok, _machine} ->
        conn
        |> put_flash(:info, "Machine deleted successfully.")
        |> redirect(to: Routes.hypervisor_machine_path(conn, :index, machine.hypervisor))

      {:error, :hypervisor, error, changes} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: Routes.hypervisor_machine_path(conn, :index, machine.hypervisor))

      {:error, :hypervisor_not_found, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Machine was not deleted successfully.")
        |> redirect(to: Routes.hypervisor_machine_path(conn, :index, machine.hypervisor))
    end
  end

  def start(conn, _params) do
    machine = conn.assigns[:machine]

    case Machines.start_machine(machine) do
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

  def stop(conn, _params) do
    machine = conn.assigns[:machine]

    case Machines.stop_machine(machine) do
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

  def poweroff(conn, _params) do
    machine = conn.assigns[:machine]

    case Machines.poweroff_machine(machine) do
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

  def console(conn, _params) do
    machine = conn.assigns[:machine]

    with {:ok, console} <- Machines.console_machine(machine) do
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
      machine = Machines.get_machine!(id, [:hypervisor, :plan, :networks])

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
    # The :index, :create and :new are under /hypervisors resource
    # for them, we use load_hypervisor which puts assign with hypervisor.
    # For other methods we're loading hypervisor from machine.
    hypervisor =
      case Map.has_key?(conn.assigns, :hypervisor) do
        true -> conn.assigns[:hypervisor]
        _ -> conn.assigns[:machine].hypervisor
      end

    conn
    |> assign(:networks, Hypervisors.list_hypervisor_networks(hypervisor))
    |> assign(:plans, Plans.list_plans())
  end

  defp load_hypervisor(conn, _) do
    try do
      %{"hypervisor_id" => id} = conn.params
      hypervisor = Hypervisors.get_hypervisor!(id)

      conn
      |> assign(:hypervisor, hypervisor)
    rescue
      _ ->
        conn
        |> put_flash(:error, "Hypervisor was not found.")
        |> redirect(to: Routes.hypervisor_path(conn, :index))
    end
  end
end
