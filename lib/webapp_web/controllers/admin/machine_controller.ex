defmodule WebappWeb.Admin.MachineController do
  use WebappWeb, :controller

  alias Webapp.{
    Machines,
    Machines.Machine,
    Hypervisors,
    Hypervisors.Hypervisor,
    Accounts,
    Accounts.User,
    Accounts.Team
  }

  plug :authorize_resource,
    model: Machine,
    non_id_actions: [:index, :create, :new],
    preload: [:hypervisor, :plan, :networks]

  plug :load_resource,
    model: Machine,
    non_id_actions: [:index, :create, :new],
    preload: [:hypervisor, :plan, :networks],
    except: [:index]

  plug :load_resource,
    model: Hypervisor,
    id_name: "hypervisor_id",
    only: [:index],
    preload: [:hypervisor_type, :machines]

  def index(conn, %{"hypervisor_id" => hypervisor_id} = _params) do
    # For action :index plug :load_resource will load all hypervisors
    hypervisors = conn.assigns[:hypervisors]
    hypervisor = Enum.find(hypervisors, fn hv -> hv.id == String.to_integer(hypervisor_id) end)

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

    machines =
      hypervisor.machines
      |> Webapp.Repo.preload([:networks, :hypervisor, :plan])

    render(conn, "index.html",
      machines: machines,
      hypervisor: hypervisor,
      status: status
    )
  end

  def index(conn, _params) do
    machines = Machines.list_machines([:hypervisor, :plan, :networks])
    render(conn, "index.html", machines: machines, hypervisor: nil)
  end
end
