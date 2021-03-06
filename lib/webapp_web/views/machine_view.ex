defmodule WebappWeb.MachineView do
  use WebappWeb, :view

  import Webapp.Machines, only: [machine_can_do?: 2]
  import Webapp.Hypervisors, only: [get_hypervisor_url: 3]

  def hypervisors_select_options(hypervisors) do
    for hypervisor <- hypervisors do
      {hypervisor.name, hypervisor.id}
    end
  end

  def networks_select_options(networks) do
    for network <- networks do
      label = "#{network.name} (#{network.network})"
      {label, network.id}
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

  def team_select_options(teams) do
    for team <- teams do
      {team.name, team.id}
    end
  end

  def ssh_public_keys_select_options(public_keys) do
    for public_key <- public_keys do
      {public_key.title, public_key.id}
    end
  end

  def map_status_to_css(status) do
    case status do
      "Creating" -> "is-light"
      "Stopped" -> "is-dark"
      "Running" -> "is-success"
      "Bootloader" -> "is-success"
      "Failed" -> "is-danger"
      _ -> "is-white"
    end
  end

  def status_icon(status) do
    case status do
      "Creating" -> "fas fa-spinner fa-spin"
      "Stopped" -> "fas fa-square"
      "Running" -> "fas fa-play"
      "Bootloader" -> "fas fa-play"
      "Failed" -> "fas fa-exclamation-circle"
      _ -> ""
    end
  end
end
