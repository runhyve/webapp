defmodule WebappWeb.MachineView do
  use WebappWeb, :view

  import Webapp.Hypervisors, only: [machine_can_do?: 2]

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

  def map_status_to_css(status) do
    case status do
      "Creating" -> "is-light"
      "Stopped" -> "is-dark"
      "Running" -> "is-success"
      "Bootloader" -> "is-success"
      _ -> "is-white"
    end
  end

  def status_icon(status) do
    case status do
      "Creating" -> "fas fa-spinner fa-spin"
      "Stopped" -> "fas fa-square"
      "Running" -> "fas fa-play"
      "Bootloader" -> "fas fa-play"
      _ -> ""
    end
  end
end
