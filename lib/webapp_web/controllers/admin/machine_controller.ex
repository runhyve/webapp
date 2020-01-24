defmodule WebappWeb.Admin.MachineController do
  use WebappWeb, :controller

  alias Webapp.{
    Machines,
    Machines.Machine,
    Hypervisors,
    Hypervisors.Hypervisor,
    Regions
  }

  plug :load_resource,
    model: Hypervisor,
    id_name: "hypervisor_id",
    only: [:index],
    preload: [:hypervisor_type, machines: Hypervisors.preload_active_machines]

  def index(conn, _params) do
    machines = Machines.list_machines([:plan, :networks, :distribution, hypervisor: :region])
    regions = Regions.list_usable_regions()
    render(conn, "index.html", machines: machines, hypervisor: nil, regions: regions)
  end
end
