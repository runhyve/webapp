defmodule WebappWeb.MachineController do
  use WebappWeb, :controller

  alias Webapp.{
    Machines,
    Machines.Machine,
    Hypervisors,
    Hypervisors.Hypervisor,
    Networks,
    Plans,
    Regions,
    Accounts,
    Accounts.User,
    Accounts.Team,
    Distributions,
    Notifications.Notifications
  }

  plug :load_and_authorize_resource,
    current_user: :current_member,
    model: Machine,
    non_id_actions: [:index, :create, :new],
    preload: [:plan, :networks, :distribution, :job, ipv4: [:ip_pool], hypervisor: :region]

  plug :load_resource,
    model: Hypervisor,
    id_name: "hypervisor_id",
    only: [:new, :create],
    preload: [:region, :hypervisor_type, machines: [:networks, :plan, :distribution]],
    required: true

  plug :load_references when action in [:new, :create, :edit, :update]

  def index(%Conn{assigns: %{current_team: %Team{} = team}} = conn, _params) do
    machines =
      Machines.list_team_machines(team, [:plan, :networks, :distribution, hypervisor: :region])

    hypervisors = Hypervisors.list_hypervisors()
    regions = Regions.list_usable_regions()

    render(conn, "index.html",
      machines: machines,
      hypervisor: false,
      hypervisors: hypervisors,
      regions: regions
    )
  end

  def new(conn, _params) do
    changeset = Machines.change_machine(%Machine{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"machine" => machine_params}) do
    Notifications.publish(
      :info,
      "#{conn.assigns.current_user.email} requested to create new VM: #{machine_params["name"]}"
    )

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
      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(
          :error,
          "Couldn't connect machine #{machine.name} to network #{network.name}"
        )
        |> redirect(to: team_path(:machine_path, conn, :show, machine))

      # Errors from changeset should be displayed!
      {:error, :machine, %Ecto.Changeset{} = _changeset, _} ->
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
  def update(conn, %{"id" => id, "machine" => %{"name" => _name} = _machine_params}) do
    machine = Machines.get_machine!(id, [:networks])

    conn
    |> put_flash(:error, "Not implemented yet.")
    |> redirect(to: team_path(:machine_path, conn, :show, machine))
  end

  def delete(conn, _params) do
    machine = conn.assigns[:machine]

    Notifications.publish(
      :info,
      "#{conn.assigns.current_user.email} requested removal of VM #{machine.name} (ID: #{machine.id})"
    )

    case Machines.delete_machine(machine) do
      {:ok, _machine} ->
        conn
        |> put_flash(:info, "Machine #{machine.name} has been marked for deletion")
        |> redirect(to: team_path(:machine_path, conn, :index))

      {:error, :hypervisor, error, _changes} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: team_path(:machine_path, conn, :index))

      {:error, :hypervisor_not_found, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(:error, "Coulnd't delete machine #{machine.name}")
        |> redirect(to: team_path(:machine_path, conn, :index))
    end
  end

  def start(conn, _params) do
    machine = conn.assigns[:machine]

    Notifications.publish(
      :info,
      "#{conn.assigns.current_user.email} requested start of VM #{machine.name} (ID: #{machine.id})"
    )

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

    Notifications.publish(
      :info,
      "#{conn.assigns.current_user.email} requested stop of VM #{machine.name} (ID: #{machine.id})"
    )

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

  def restart(conn, _params) do
    machine = conn.assigns[:machine]

    Notifications.publish(
      :info,
      "#{conn.assigns.current_user.email} requested to restart VM #{machine.name} (ID: #{machine.id})"
    )

    case Machines.restart_machine(machine) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Machine #{machine.name} is being restarted")
        |> redirect(to: team_path(:machine_path, conn, :show, machine))

      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: team_path(:machine_path, conn, :show, machine))
    end
  end

  def poweroff(conn, _params) do
    machine = conn.assigns[:machine]

    Notifications.publish(
      :info,
      "#{conn.assigns.current_user.email} requested to poweroff VM #{machine.name} (ID: #{machine.id})"
    )

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

    Notifications.publish(
      :info,
      "#{conn.assigns.current_user.email} requested access to serial console of VM #{machine.name} (ID: #{machine.id})"
    )

    case Machines.console_machine(machine) do
      {:ok, console} ->
        token = Base.encode64(console["user"] <> ":" <> console["password"])
        render(conn, "console.html", machine: machine, console: console, token: token)

      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: team_path(:machine_path, conn, :show, machine))
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
    |> assign(:distributions, Distributions.list_active_distributions())
  end
end
