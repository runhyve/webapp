defmodule WebappWeb.MachineView do
  use WebappWeb, :view

  def hypervisors_select_options(hypervisors) do

    for hypervisor <- hypervisors do
      label = hypervisor.name <> " (" <> hypervisor.ip_address <> ")"
      {label, hypervisor.id}
    end
  end
end
