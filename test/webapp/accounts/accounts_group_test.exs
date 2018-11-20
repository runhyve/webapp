defmodule Webapp.AccountsGroupTest do
  use Webapp.DataCase

  alias Webapp.Accounts
  alias Webapp.Accounts.Group

  @valid_group %{name: "some name", namespace: %{namespace: "another-company"}}
  @invalid_group %{name: nil}
  
  @update_group %{name: "some updated name"}

  def group_fixture(attrs \\ %{}) do
    {:ok, group} =
      attrs
      |> Enum.into(@valid_group)
      |> Accounts.create_group()

    group
  end

  test "list_groups/0 returns all groups" do
    group = group_fixture()
    assert Accounts.list_groups([:namespace]) == [group]
  end

  test "get_group!/1 returns the group with given id" do
    group = group_fixture()
    assert Accounts.get_group!(group.id, [:namespace]) == group
  end

  test "create_group/1 with valid data creates a group" do
    assert {:ok, %Group{} = group} = Accounts.create_group(@valid_group)
    assert group.name == "some name"
  end

  test "create_group/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Accounts.create_group(@invalid_group)
  end

  test "update_group/2 with valid data updates the group" do
    group = group_fixture()
    assert {:ok, %Group{} = group} = Accounts.update_group(group, @update_group)
    assert group.name == "some updated name"
  end

  test "update_group/2 with invalid data returns error changeset" do
    group = group_fixture()
    assert {:error, %Ecto.Changeset{}} = Accounts.update_group(group, @invalid_group)
    assert group == Accounts.get_group!(group.id, [:namespace])
  end

  test "delete_group/1 deletes the group" do
    group = group_fixture()
    assert {:ok, %Group{}} = Accounts.delete_group(group)
    assert_raise Ecto.NoResultsError, fn -> Accounts.get_group!(group.id) end
  end

  test "change_group/1 returns a group changeset" do
    group = group_fixture()
    assert %Ecto.Changeset{} = Accounts.change_group(group)
  end
end
