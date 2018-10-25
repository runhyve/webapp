defmodule WebappWeb.HypervisorView do
  use WebappWeb, :view

  def hypervisor_types_select_options(hypervisor_types) do
    for type <- hypervisor_types, do: {type.name, type.id}
  end
end
