defmodule WebappWeb.Admin.HypervisorView do
  use WebappWeb, :view

  def hypervisor_types_select_options(hypervisor_types) do
    for type <- hypervisor_types, do: {type.name, type.id}
  end

  def map_status_to_css(status) do
    case status do
      "unreachable" -> "is-danger"
      "healthy" -> "is-success"
      _ -> "is-light"
    end
  end

  def status_icon(status) do
    case status do
      "healthy" -> "fas fa-check"
      "unreachable" -> "fas fa-exclamation-triangle"
      _ -> ""
    end
  end
end
