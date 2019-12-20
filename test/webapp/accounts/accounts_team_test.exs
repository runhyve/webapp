defmodule Webapp.AccountsTeamTest do
  use Webapp.DataCase

  alias Webapp.Accounts
  alias Webapp.Accounts.Team

  @valid_team %{name: "some name", namespace: "another-company"}
  @invalid_team %{name: nil}

  @update_team %{name: "some updated name"}

  def team_fixture(_attrs \\ %{}) do
    {:ok, fixtures} =
      Accounts.register_user(%{
        user_email: "fred@example.com",
        user_password: "reallyHard2gue$$",
        user_name: "fred",
        team_name: "company",
        team_namespace: "company"
      })

    # {:ok, team} =
    #   attrs
    #   |> Enum.into(@valid_team)
    #   |> Accounts.create_team()

    fixtures
  end

  test "list_teams/0 returns all teams" do
    %{team: team} = team_fixture()
    assert Accounts.list_teams() == [team]
  end

  test "get_team!/1 returns the team with given id" do
    %{team: team} = team_fixture()
    assert Accounts.get_team!(team.id) == team
  end

  test "create_team/1 with valid data creates a team" do
    %{team: _team, user: user} = team_fixture()

    team_params = Map.merge(@valid_team, %{members: [%{user_id: user.id, role: "Administrator"}]})

    assert {:ok, %Team{} = team} = Accounts.create_team(team_params)
    assert team.name == "some name"
  end

  test "create_team/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Accounts.create_team(@invalid_team)
  end

  test "update_team/2 with valid data updates the team" do
    %{team: team, user: _user} = team_fixture()
    assert {:ok, %Team{} = team} = Accounts.update_team(team, @update_team)
    assert team.name == "some updated name"
  end

  test "update_team/2 with invalid data returns error changeset" do
    %{team: team, user: _user} = team_fixture()
    assert {:error, %Ecto.Changeset{}} = Accounts.update_team(team, @invalid_team)
    assert team == Accounts.get_team!(team.id)
  end

  #
  #  test "delete_team/1 deletes the team" do
  #    team = team_fixture()
  #    assert {:ok, %Team{}} = Accounts.delete_team(team)
  #    assert_raise Ecto.NoResultsError, fn -> Accounts.get_team!(team.id) end
  #  end
  #
  test "change_team/1 returns a team changeset" do
    %{team: team, user: _user} = team_fixture()
    assert %Ecto.Changeset{} = Accounts.change_team(team)
  end
end
