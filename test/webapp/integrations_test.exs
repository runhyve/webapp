defmodule Webapp.IntegrationsTest do
  use Webapp.DataCase

  alias Webapp.Integrations

  describe "chefservers" do
    alias Webapp.Integrations.ChefServer

    @valid_attrs %{cacert: "some cacert", enabled: true, private_key: "some private_key", url: "some url", username: "some username"}
    @update_attrs %{cacert: "some updated cacert", enabled: false, private_key: "some updated private_key", url: "some updated url", username: "some updated username"}
    @invalid_attrs %{cacert: nil, enabled: nil, private_key: nil, url: nil, username: nil}

    def chef_server_fixture(attrs \\ %{}) do
      {:ok, chef_server} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Integrations.create_chef_server()

      chef_server
    end

    test "list_chefservers/0 returns all chefservers" do
      chef_server = chef_server_fixture()
      assert Integrations.list_chefservers() == [chef_server]
    end

    test "get_chef_server!/1 returns the chef_server with given id" do
      chef_server = chef_server_fixture()
      assert Integrations.get_chef_server!(chef_server.id) == chef_server
    end

    test "create_chef_server/1 with valid data creates a chef_server" do
      assert {:ok, %ChefServer{} = chef_server} = Integrations.create_chef_server(@valid_attrs)
      assert chef_server.cacert == "some cacert"
      assert chef_server.enabled == true
      assert chef_server.private_key == "some private_key"
      assert chef_server.url == "some url"
      assert chef_server.username == "some username"
    end

    test "create_chef_server/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Integrations.create_chef_server(@invalid_attrs)
    end

    test "update_chef_server/2 with valid data updates the chef_server" do
      chef_server = chef_server_fixture()
      assert {:ok, %ChefServer{} = chef_server} = Integrations.update_chef_server(chef_server, @update_attrs)
      assert chef_server.cacert == "some updated cacert"
      assert chef_server.enabled == false
      assert chef_server.private_key == "some updated private_key"
      assert chef_server.url == "some updated url"
      assert chef_server.username == "some updated username"
    end

    test "update_chef_server/2 with invalid data returns error changeset" do
      chef_server = chef_server_fixture()
      assert {:error, %Ecto.Changeset{}} = Integrations.update_chef_server(chef_server, @invalid_attrs)
      assert chef_server == Integrations.get_chef_server!(chef_server.id)
    end

    test "delete_chef_server/1 deletes the chef_server" do
      chef_server = chef_server_fixture()
      assert {:ok, %ChefServer{}} = Integrations.delete_chef_server(chef_server)
      assert_raise Ecto.NoResultsError, fn -> Integrations.get_chef_server!(chef_server.id) end
    end

    test "change_chef_server/1 returns a chef_server changeset" do
      chef_server = chef_server_fixture()
      assert %Ecto.Changeset{} = Integrations.change_chef_server(chef_server)
    end
  end
end
