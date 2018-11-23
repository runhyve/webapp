defmodule Webapp.AccountsTeamTest do
  use Webapp.DataCase

  alias Webapp.Accounts
  alias Webapp.Accounts.Team

  @valid_group %{name: "some name", namespace: %{namespace: "another-company"}}
  @invalid_group %{name: nil}

  @update_team %{name: "some updated name"}

  def group_fixture(attrs \\ %{}) do
    {:ok, group} =
      attrs
      |> Enum.into(@valid_group)
      |> Accounts.create_team()

    group
  end

  test "list_teams/0 returns all groups" do
    group = group_fixture()
    assert Accounts.list_teams([:namespace]) == [group]
  end

  test "get_team!/1 returns the group with given id" do
    group = group_fixture()
    assert Accounts.get_team!(group.id, [:namespace]) == group
  end

  test "create_team/1 with valid data creates a group" do
    assert {:ok, %Team{} = group} = Accounts.create_team(@valid_group)
    assert group.name == "some name"
  end

  test "create_team/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Accounts.create_team(@invalid_group)
  end

  test "update_team/2 with valid data updates the group" do
    group = group_fixture()
    assert {:ok, %Team{} = group} = Accounts.update_team(group, @update_team)
    assert group.name == "some updated name"
  end

  test "update_team/2 with invalid data returns error changeset" do
    group = group_fixture()
    assert {:error, %Ecto.Changeset{}} = Accounts.update_team(group, @invalid_group)
    assert group == Accounts.get_team!(group.id, [:namespace])
  end

  test "delete_team/1 deletes the group" do
    group = group_fixture()
    assert {:ok, %Team{}} = Accounts.delete_team(group)
    assert_raise Ecto.NoResultsError, fn -> Accounts.get_team!(group.id) end
  end

  test "change_team/1 returns a group changeset" do
    group = group_fixture()
    assert %Ecto.Changeset{} = Accounts.change_team(group)
  end
end
