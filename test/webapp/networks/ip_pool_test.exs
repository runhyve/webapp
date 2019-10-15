defmodule Webapp.IpPoolTest do
  use Webapp.DataCase
  use Webapp.HypervisorCase

  alias Webapp.{
    Networks,
    Networks.Ip_pool
  }

  describe "ip_pools context" do
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

    @valid_attrs %{"name" => "test", "gateway" => "192.168.0.1", "netmask" => "255.255.255.240", "ip_range" => "192.168.0.0/28", "list" => ip_list}
    #@update_attrs %{gateway: 43, netmask: 43}
    @invalid_attrs %{gateway: nil, netmask: nil}

    def ip_pool_fixture(attrs \\ %{}) do
      {:ok, %{ip_pool: ip_pool}} = attrs
        |> Enum.into(@valid_attrs)
        |> Networks.create_ip_pool()

      ip_pool
    end

    test "list_ip_pools/0 returns all ip_pools", %{network: network} do
      ip_pool = ip_pool_fixture(%{"network_id" => network.id})

      assert Networks.list_ip_pools([]) == [ip_pool]
    end

    test "get_ip_pool!/1 returns the ip_pool with given id", %{network: network} do
      ip_pool = ip_pool_fixture(%{"network_id" => network.id})
      assert Networks.get_ip_pool!(ip_pool.id, []) == ip_pool
    end

    test "create_ip_pool/1 sets gateway ipv4 as reserved", %{network: network} do
      ip_pool = ip_pool_fixture(%{"network_id" => network.id})
      ip_pool = Networks.get_ip_pool!(ip_pool.id, [:ipv4])

      gateway = Enum.find(ip_pool.ipv4, fn ipv4 -> ipv4.ip == ip_pool.gateway end)
      assert gateway.reserved == true
    end

    test "create_ip_pool/1 with valid data creates a ip_pool", %{network: network} do
      attrs = %{"network_id" => network.id}
              |> Enum.into(@valid_attrs)

      assert {:ok, %{ip_pool: ip_pool}} = Networks.create_ip_pool(attrs)

      assert ip_pool.gateway.address == parse_ip_address("192.168.0.1")
      assert ip_pool.netmask.address == parse_ip_address("255.255.255.240")
      assert ip_pool.name == "test"
    end

    test "create_ip_pool/1 with invalid data returns error changeset" do
      assert {:error, :ip_pool, %Ecto.Changeset{}, _changes_so_far} = Networks.create_ip_pool(@invalid_attrs)
    end

    test "change_ip_pool/1 returns a ip_pool changeset", %{network: network}  do
      ip_pool = ip_pool_fixture(%{"network_id" => network.id})
      assert %Ecto.Changeset{} = Networks.change_ip_pool(ip_pool)
    end
  end

  describe "ip_pool model" do
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

    @valid_attrs %{"name" => "test", "gateway" => "192.168.0.1", "netmask" => "255.255.255.240", "ip_range" => "192.168.0.0/28", "list" => ip_list}

    test "validate_ipv4_list/2 accepts only valid ip list", %{network: network} do
      attrs = %{"network_id" => network.id}
              |> Enum.into(@valid_attrs)

      changeset = Ip_pool.changeset(%Ip_pool{}, attrs)

      assert changeset.valid?
    end

    test "validate_ipv4_list/2 returns error with invalid ip address in list", %{network: network} do
      ip_list = """
            192.168.0.1
            this.is.not.valid
      """
      attrs = %{"network_id" => network.id, "list" => ip_list}
              |> Enum.into(@valid_attrs)

      changeset = Ip_pool.changeset(%Ip_pool{}, attrs)

      refute changeset.valid?
      assert changeset.errors == [list: {"Please provide valid IP addresses", []}]
    end

    test "validate_ipv4_range/2 accepts only valid ip range", %{network: network} do
      attrs = %{"network_id" => network.id}
              |> Enum.into(@valid_attrs)

      changeset = Ip_pool.changeset(%Ip_pool{}, attrs)

      assert changeset.valid?
    end

    test "validate_ipv4_range/2 returns error with invalid ip range", %{network: network} do
      attrs = %{"network_id" => network.id, "ip_range" => "192.168.0.10-1/12"}
              |> Enum.into(@valid_attrs)

      changeset = Ip_pool.changeset(%Ip_pool{}, attrs)

      refute changeset.valid?
      assert changeset.errors == [ip_range: {"Please provide valid IP Range", []}]
    end

    test "validate_ipv4_list_in_range/2 returns error when ip addresses from list does not match ip range", %{network: network} do
      ip_list = """
            192.168.0.1
            10.0.1.2
      """
      attrs = %{"network_id" => network.id, "list" => ip_list}
              |> Enum.into(@valid_attrs)

      changeset = Ip_pool.changeset(%Ip_pool{}, attrs)

      refute changeset.valid?
      assert changeset.errors == [list: {"Provided IP addresses does not match IP Range", []}]
    end
  end

  def parse_ip_address(ip_address) do
    {:ok, ip_address} = ip_address
                        |> String.to_charlist()
                        |> :inet.parse_address()

    ip_address
  end
end
