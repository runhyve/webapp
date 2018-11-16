defmodule Webapp.MachinesTest do
  use Webapp.DataCase

  alias Webapp.Machines

  describe "machines" do
    #    alias Webapp.Machines.Machine
    #
    #    @valid_attrs %{name: "some name", template: "some template"}
    #    @update_attrs %{name: "some updated name", template: "some updated template"}
    #    @invalid_attrs %{name: nil, template: nil}
    #
    #    def machine_fixture(attrs \\ %{}) do
    #      {:ok, machine} =
    #        attrs
    #        |> Enum.into(@valid_attrs)
    #        |> Machines.create_machine()
    #
    #      machine
    #    end
    #
    #    test "list_machines/0 returns all machines" do
    #      machine = machine_fixture()
    #      assert Machines.list_machines() == [machine]
    #    end
    #
    #    test "get_machine!/1 returns the machine with given id" do
    #      machine = machine_fixture()
    #      assert Machines.get_machine!(machine.id) == machine
    #    end
    #
    #    test "create_machine/1 with valid data creates a machine" do
    #      assert {:ok, %Machine{} = machine} = Machines.create_machine(@valid_attrs)
    #      assert machine.name == "some name"
    #      assert machine.template == "some template"
    #    end
    #
    #    test "create_machine/1 with invalid data returns error changeset" do
    #      assert {:error, %Ecto.Changeset{}} = Machines.create_machine(@invalid_attrs)
    #    end
    #
    #    test "update_machine/2 with valid data updates the machine" do
    #      machine = machine_fixture()
    #      assert {:ok, %Machine{} = machine} = Machines.update_machine(machine, @update_attrs)
    #
    #
    #      assert machine.name == "some updated name"
    #      assert machine.template == "some updated template"
    #    end
    #
    #    test "update_machine/2 with invalid data returns error changeset" do
    #      machine = machine_fixture()
    #      assert {:error, %Ecto.Changeset{}} = Machines.update_machine(machine, @invalid_attrs)
    #      assert machine == Machines.get_machine!(machine.id)
    #    end
    #
    #    test "delete_machine/1 deletes the machine" do
    #      machine = machine_fixture()
    #      assert {:ok, %Machine{}} = Machines.delete_machine(machine)
    #      assert_raise Ecto.NoResultsError, fn -> Machines.get_machine!(machine.id) end
    #    end
    #
    #    test "change_machine/1 returns a machine changeset" do
    #      machine = machine_fixture()
    #      assert %Ecto.Changeset{} = Machines.change_machine(machine)
    #    end
  end
end
