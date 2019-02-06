defmodule WebappWeb.MachineController do
  use WebappWeb, :controller

  alias Webapp.{
    Machines,
    Machines.Machine,
    Hypervisors,
    Networks,
    Plans,
    Accounts,
    Accounts.User,
    Accounts.Team
  }

  plug :load_resource,
    model: Machine,
    non_id_actions: [:index, :create, :new],
    preload: [:hypervisor, :plan, :networks]

  plug :authorize_resource,
    current_user: :current_member,
    model: Machine,
    non_id_actions: [:index, :create, :new],
    preload: [:hypervisor, :plan, :networks]

  plug :load_hypervisor when action in [:new, :create]
  plug :load_references when action in [:new, :create, :edit, :update]

  #  def index(conn, %{"hypervisor_id" => hypervisor_id} = params) do
  #    conn = load_hypervisor(conn, params)
  #    hypervisor = conn.assigns[:hypervisor]
  #    machines = Hypervisors.list_hypervisor_machines(hypervisor, [:hypervisor, :plan, :networks])
  #
  #    # @TODO: Refactor this
  #    status =
  #      case Hypervisors.update_hypervisor_status(hypervisor) do
  #        {:ok, status} -> status
  #        {:error, _} -> "unreachable"
  #      end
  #
  #    conn =
  #      if status == "unreachable" do
  #        put_flash(conn, :error, "Failed to fetch hypervisor status")
  #      else
  #        conn
  #      end
  #
  #    render(conn, "index.html", machines: machines, hypervisor: hypervisor, status: status)
  #  end

  def admin_index(%Conn{assigns: %{current_user: %User{role: "Administrator"}}} = conn, _params) do
    machines = Machines.list_team_machines([:hypervisor, :plan, :networks])
    hypervisors = Hypervisors.list_hypervisors()

    render(conn, "admin/index.html",
      machines: machines,
      hypervisor: false,
      hypervisors: hypervisors
    )
  end

  # My machines
  def index(%Conn{assigns: %{current_team: %Team{} = team}} = conn, _params) do
    machines = Machines.list_team_machines(team, [:hypervisor, :plan, :networks])
    hypervisors = Hypervisors.list_hypervisors()

    render(conn, "index.html", machines: machines, hypervisor: false, hypervisors: hypervisors)
  end

  def new(conn, _params) do
    changeset = Machines.change_machine(%Machine{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"machine" => machine_params}) do
    case Machines.create_machine(machine_params) do
      {:ok, %{machine: machine}} ->
        conn
        |> redirect(to: team_path(:machine_path, conn, :show, machine))

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
        |> put_flash(:error, "Couldn't spawn new machine.")
        |> render("new.html", changeset: changeset)
    end
  end

  def show(conn, _params) do
    machine = conn.assigns[:machine]

    case Machines.update_status(machine) do
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
        |> put_flash(:info, "Machine #{machine.name} is now connected to network #{network.name}")
        |> redirect(to: team_path(:machine_path, conn, :show, machine))

      # Errors from changeset should be displayed!
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(
          :error,
          "Couldn't connect machine #{machine.name} to network #{network.name}"
        )
        |> redirect(to: team_path(:machine_path, conn, :show, machine))

      # Errors from changeset should be displayed!
      {:error, :machine, %Ecto.Changeset{} = changeset, _} ->
        conn
        |> put_flash(
          :error,
          "Couldn't connect machine #{machine.name} to network #{network.name}"
        )
        |> redirect(to: team_path(:machine_path, conn, :show, machine))

      {:error, :hypervisor, error, _} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: team_path(:machine_path, conn, :show, machine))

      {:error, :hypervisor_not_found} ->
        conn
        |> put_flash(:error, "Couldn't create virtual machine")
        |> redirect(to: team_path(:machine_path, conn, :show, machine))
    end
  end

  # Change machine name
  def update(conn, %{"id" => id, "machine" => %{"name" => name} = machine_params}) do
    machine = Machines.get_machine!(id, [:networks])

    conn
    |> put_flash(:error, "Not implemented yet.")
    |> redirect(to: team_path(:machine_path, conn, :show, machine))
  end

  def delete(conn, _params) do
    machine = conn.assigns[:machine]

    case Machines.delete_machine(machine) do
      {:ok, _machine} ->
        conn
        |> put_flash(:info, "Machine #{machine.name} has been deleted")
        |> redirect(to: team_path(:machine_path, conn, :index))

      {:error, :hypervisor, error, changes} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: team_path(:machine_path, conn, :index))

      {:error, :hypervisor_not_found, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Coulnd't delete machine #{machine.name}")
        |> redirect(to: team_path(:machine_path, conn, :index))
    end
  end

  def start(conn, _params) do
    machine = conn.assigns[:machine]

    case Machines.start_machine(machine) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Machine #{machine.name} is being started")
        |> redirect(to: team_path(:machine_path, conn, :show, machine))

      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: team_path(:machine_path, conn, :show, machine))
    end
  end

  def stop(conn, _params) do
    machine = conn.assigns[:machine]

    case Machines.stop_machine(machine) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Machine #{machine.name} is being stopped")
        |> redirect(to: team_path(:machine_path, conn, :show, machine))

      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: team_path(:machine_path, conn, :show, machine))
    end
  end

  def poweroff(conn, _params) do
    machine = conn.assigns[:machine]

    case Machines.poweroff_machine(machine) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Machine #{machine.name} is being powered off")
        |> redirect(to: team_path(:machine_path, conn, :show, machine))

      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: team_path(:machine_path, conn, :show, machine))
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
        |> redirect(to: team_path(:machine_path, conn, :show, machine))
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
        |> redirect(to: team_path(:machine_path, conn, :index))
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
    |> assign(:teams, Accounts.list_teams())
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
        |> redirect(to: team_path(:page_path, conn, :index))
    end
  end
end
