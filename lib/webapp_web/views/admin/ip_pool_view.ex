defmodule WebappWeb.Admin.Ip_poolView do
  use WebappWeb, :view

  def networks_select_options(networks) do
    for network <- networks, do: {"#{network.name}@#{network.hypervisor.name}", network.id}
  end

  def count_used_ips(ips) do
    ips
    |> Enum.filter(fn ip -> ipv4_is_available?(ip) == false end)
    |> Enum.count()
  end

  def ipv4_is_available?(ip) do
    ip.machine_id == nil && ip.reserved == false
  end
end
