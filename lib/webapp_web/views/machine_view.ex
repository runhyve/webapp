defmodule WebappWeb.MachineView do
  use WebappWeb, :view

  def hypervisors_select_options(hypervisors) do
    for hypervisor <- hypervisors do
      label = hypervisor.name <> " (" <> hypervisor.ip_address <> ")"
      {label, hypervisor.id}
    end
  end

  def plans_select_options(plans) do
    for plan <- plans do
      details = [
        Integer.to_string(plan.storage),
        Integer.to_string(plan.ram),
        Integer.to_string(plan.cpu)
      ]

      label = plan.name <> " (" <> Enum.join(details, "/") <> ")"
      {label, plan.id}
    end
  end
end
