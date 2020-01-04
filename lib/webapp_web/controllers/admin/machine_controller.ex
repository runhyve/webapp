defmodule WebappWeb.Admin.MachineController do
  use WebappWeb, :controller

  alias Webapp.{
    Machines,
    Machines.Machine,
    Hypervisors,
    Hypervisors.Hypervisor
  }

  plug :load_resource,
    model: Hypervisor,
    id_name: "hypervisor_id",
    only: [:index],
    preload: [:hypervisor_type, machines: Hypervisors.preload_active_machines]

  def index(conn, _params) do
    machines = Machines.list_machines([:hypervisor, :plan, :networks, :distribution])
    render(conn, "index.html", machines: machines, hypervisor: nil)
  end
end
