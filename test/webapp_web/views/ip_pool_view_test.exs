defmodule WebappWeb.IpPoolViewTest do
  use WebappWeb.ConnCase, async: true

  alias Webapp.Networks
  alias WebappWeb.Admin.Ip_poolView

  ip_list = """
      192.168.0.1
      192.168.0.2
      192.168.0.3
      192.168.0.4
      192.168.0.5
      192.168.0.6
      192.168.0.7
      192.168.0.8
      192.168.0.9
      192.168.0.10
      192.168.0.11
      192.168.0.12
      192.168.0.13
      192.168.0.14
  """

  @valid_attrs %{"name" => "test_view_pool", "gateway" => "192.168.0.1", "netmask" => "255.255.255.240", "ip_range" => "192.168.0.0/28", "list" => ip_list}

  def ip_pool_fixture(attrs \\ %{}) do
    {:ok, %{ip_pool: ip_pool}} = attrs
                                 |> Enum.into(@valid_attrs)
                                 |> Networks.create_ip_pool()

    ip_pool
  end

  test "count_used_ips/1" do
    hypervisor_type = fixture_hypervisor_type(%{name: "bhyve"})
    region = fixture_region(%{name: "region"})

    hypervisor =
      fixture_hypervisor(%{
        name: "test_hypervisor_1",
        ip_address: "192.168.199.254",
        hypervisor_type_id: hypervisor_type.id,
        region_id: region.id,
        fqdn: "http://192.168.199.254.xip.io",
        webhook_token: "Eus3oghas3loo0nietur1eighao5ciay",
        tls: false,
      })

    network = fixture_network(%{
      name: "test_network_1",
      network: "0.0.0.0/32",
      hypervisor_id: hypervisor.id
    })

    ip_pool = ip_pool_fixture(%{"network_id" => network.id})
    ip_pool = Networks.get_ip_pool!(ip_pool.id, [:ipv4])

    assert 14 == Enum.count(ip_pool.ipv4)
    assert 1 == Ip_poolView.count_used_ips(ip_pool.ipv4)
  end
end
