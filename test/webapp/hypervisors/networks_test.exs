defmodule Webapp.Hypervisors.NetworksTest do
  use Webapp.DataCase

  # alias Webapp.Networks

  describe "networks" do
    # alias Webapp.Networks.Network

    #    @valid_attrs %{name: "some name", network: "some network"}
    #    @update_attrs %{name: "some updated name", network: "some updated network"}
    #    @invalid_attrs %{name: nil, network: nil}
    #
    #    def network_fixture(attrs \\ %{}) do
    #      {:ok, network} =
    #        attrs
    #        |> Enum.into(@valid_attrs)
    #        |> Networks.create_network()
    #
    #      network
    #    end
    #
    #    test "list_networks/0 returns all networks" do
    #      network = network_fixture()
    #      assert Networks.list_networks() == [network]
    #    end
    #
    #    test "get_network!/1 returns the network with given id" do
    #      network = network_fixture()
    #      assert Networks.get_network!(network.id) == network
    #    end
    #
    #    test "create_network/1 with valid data creates a network" do
    #      assert {:ok, %Network{} = network} = Networks.create_network(@valid_attrs)
    #      assert network.name == "some name"
    #      assert network.network == "some network"
    #    end
    #
    #    test "create_network/1 with invalid data returns error changeset" do
    #      assert {:error, %Ecto.Changeset{}} = Networks.create_network(@invalid_attrs)
    #    end
    #
    #    test "update_network/2 with valid data updates the network" do
    #      network = network_fixture()
    #      assert {:ok, %Network{} = network} = Networks.update_network(network, @update_attrs)
    #      assert network.name == "some updated name"
    #      assert network.network == "some updated network"
    #    end
    #
    #    test "update_network/2 with invalid data returns error changeset" do
    #      network = network_fixture()
    #      assert {:error, %Ecto.Changeset{}} = Networks.update_network(network, @invalid_attrs)
    #      assert network == Networks.get_network!(network.id)
    #    end
    #
    #    test "delete_network/1 deletes the network" do
    #      network = network_fixture()
    #      assert {:ok, %Network{}} = Networks.delete_network(network)
    #      assert_raise Ecto.NoResultsError, fn -> Networks.get_network!(network.id) end
    #    end
    #
    #    test "change_network/1 returns a network changeset" do
    #      network = network_fixture()
    #      assert %Ecto.Changeset{} = Networks.change_network(network)
    #    end
  end
end
