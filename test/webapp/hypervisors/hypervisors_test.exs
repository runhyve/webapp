defmodule Webapp.HypervisorsTest do
  use Webapp.DataCase

  alias Webapp.Hypervisors

  describe "hypervisor_types" do
    alias Webapp.Hypervisors.Type

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def type_fixture(attrs \\ %{}) do
      {:ok, type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Hypervisors.create_type()

      type
    end

    test "list_hypervisor_types/0 returns all hypervisor_types" do
      type = type_fixture()
      assert Hypervisors.list_hypervisor_types() == [type]
    end

    test "get_type!/1 returns the type with given id" do
      type = type_fixture()
      assert Hypervisors.get_type!(type.id) == type
    end

    test "create_type/1 with valid data creates a type" do
      assert {:ok, %Type{} = type} = Hypervisors.create_type(@valid_attrs)
      assert type.name == "some name"
    end

    test "create_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Hypervisors.create_type(@invalid_attrs)
    end

    test "update_type/2 with valid data updates the type" do
      type = type_fixture()
      assert {:ok, %Type{} = type} = Hypervisors.update_type(type, @update_attrs)

      assert type.name == "some updated name"
    end

    test "update_type/2 with invalid data returns error changeset" do
      type = type_fixture()
      assert {:error, %Ecto.Changeset{}} = Hypervisors.update_type(type, @invalid_attrs)
      assert type == Hypervisors.get_type!(type.id)
    end

    test "delete_type/1 deletes the type" do
      type = type_fixture()
      assert {:ok, %Type{}} = Hypervisors.delete_type(type)
      assert_raise Ecto.NoResultsError, fn -> Hypervisors.get_type!(type.id) end
    end

    test "change_type/1 returns a type changeset" do
      type = type_fixture()
      assert %Ecto.Changeset{} = Hypervisors.change_type(type)
    end
  end

  describe "hypervisor" do
    #    alias Webapp.Hypervisors.Hypervisor
    #
    #    @valid_attrs %{ip_address: "127.0.0.1", name: "some name"}
    #    @update_attrs %{ip_address: "172.16.0.1", name: "some updated name"}
    #    @invalid_attrs %{ip_address: nil, name: nil}
    #
    #    def hypervisor_fixture(attrs \\ %{}) do
    #      {:ok, hypervisor} =
    #        attrs
    #        |> Enum.into(@valid_attrs)
    #        |> Hypervisors.create_hypervisor()
    #
    #      hypervisor
    #    end
    #
    #    test "list_hypervisor/0 returns all hypervisor" do
    #      hypervisor = hypervisor_fixture()
    #      assert Hypervisors.list_hypervisor() == [hypervisor]
    #    end
    #
    #    test "get_hypervisor!/1 returns the hypervisor with given id" do
    #      hypervisor = hypervisor_fixture()
    #      assert Hypervisors.get_hypervisor!(hypervisor.id) == hypervisor
    #    end
    #
    #    test "create_hypervisor/1 with valid data creates a hypervisor" do
    #      assert {:ok, %Hypervisor{} = hypervisor} = Hypervisors.create_hypervisor(@valid_attrs)
    #      assert hypervisor.ip_address == "some ip_address"
    #      assert hypervisor.name == "some name"
    #    end
    #
    #    test "create_hypervisor/1 with invalid data returns error changeset" do
    #      assert {:error, %Ecto.Changeset{}} = Hypervisors.create_hypervisor(@invalid_attrs)
    #    end
    #
    #    test "update_hypervisor/2 with valid data updates the hypervisor" do
    #      hypervisor = hypervisor_fixture()
    #      assert {:ok, %Hypervisor{} = hypervisor} = Hypervisors.update_hypervisor(hypervisor, @update_attrs)
    #
    #
    #      assert hypervisor.ip_address == "some updated ip_address"
    #      assert hypervisor.name == "some updated name"
    #    end
    #
    #    test "update_hypervisor/2 with invalid data returns error changeset" do
    #      hypervisor = hypervisor_fixture()
    #      assert {:error, %Ecto.Changeset{}} = Hypervisors.update_hypervisor(hypervisor, @invalid_attrs)
    #      assert hypervisor == Hypervisors.get_hypervisor!(hypervisor.id)
    #    end
    #
    #    test "delete_hypervisor/1 deletes the hypervisor" do
    #      hypervisor = hypervisor_fixture()
    #      assert {:ok, %Hypervisor{}} = Hypervisors.delete_hypervisor(hypervisor)
    #      assert_raise Ecto.NoResultsError, fn -> Hypervisors.get_hypervisor!(hypervisor.id) end
    #    end
    #
    #    test "change_hypervisor/1 returns a hypervisor changeset" do
    #      hypervisor = hypervisor_fixture()
    #      assert %Ecto.Changeset{} = Hypervisors.change_hypervisor(hypervisor)
    #    end
  end

  describe "machines" do
    #    alias Webapp.Hypervisors.Machine
    #
    #    @valid_attrs %{name: "some name", template: "some template"}
    #    @update_attrs %{name: "some updated name", template: "some updated template"}
    #    @invalid_attrs %{name: nil, template: nil}
    #
    #    def machine_fixture(attrs \\ %{}) do
    #      {:ok, machine} =
    #        attrs
    #        |> Enum.into(@valid_attrs)
    #        |> Hypervisors.create_machine()
    #
    #      machine
    #    end
    #
    #    test "list_machines/0 returns all machines" do
    #      machine = machine_fixture()
    #      assert Hypervisors.list_machines() == [machine]
    #    end
    #
    #    test "get_machine!/1 returns the machine with given id" do
    #      machine = machine_fixture()
    #      assert Hypervisors.get_machine!(machine.id) == machine
    #    end
    #
    #    test "create_machine/1 with valid data creates a machine" do
    #      assert {:ok, %Machine{} = machine} = Hypervisors.create_machine(@valid_attrs)
    #      assert machine.name == "some name"
    #      assert machine.template == "some template"
    #    end
    #
    #    test "create_machine/1 with invalid data returns error changeset" do
    #      assert {:error, %Ecto.Changeset{}} = Hypervisors.create_machine(@invalid_attrs)
    #    end
    #
    #    test "update_machine/2 with valid data updates the machine" do
    #      machine = machine_fixture()
    #      assert {:ok, %Machine{} = machine} = Hypervisors.update_machine(machine, @update_attrs)
    #
    #
    #      assert machine.name == "some updated name"
    #      assert machine.template == "some updated template"
    #    end
    #
    #    test "update_machine/2 with invalid data returns error changeset" do
    #      machine = machine_fixture()
    #      assert {:error, %Ecto.Changeset{}} = Hypervisors.update_machine(machine, @invalid_attrs)
    #      assert machine == Hypervisors.get_machine!(machine.id)
    #    end
    #
    #    test "delete_machine/1 deletes the machine" do
    #      machine = machine_fixture()
    #      assert {:ok, %Machine{}} = Hypervisors.delete_machine(machine)
    #      assert_raise Ecto.NoResultsError, fn -> Hypervisors.get_machine!(machine.id) end
    #    end
    #
    #    test "change_machine/1 returns a machine changeset" do
    #      machine = machine_fixture()
    #      assert %Ecto.Changeset{} = Hypervisors.change_machine(machine)
    #    end
  end
end
