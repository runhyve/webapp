defmodule Webapp.AccountsUserTest do
  use Webapp.DataCase

  alias Webapp.Accounts
  alias Webapp.Accounts.User

  @valid_user %{
    user_email: "fred@example.com",
    user_password: "reallyHard2gue$$",
    user_name: "fred",
    team_name: "company",
    team_namespace: "company"
  }
  @invalid_namespace %{
    user_email: "fred@example.com",
    user_password: "reallyHard2gue$$",
    user_name: "fred",
    team_name: "company"
  }
  @invalid_user %{user_email: "invalid#email", user_password: ""}

  @update_attrs %{email: "frederick@example.com", name: "frederick"}
  @invalid_update_attrs %{email: "frederick#example.com", name: "frederick"}

  @user_attrs [
    :email,
    :password_digest,
    :username,
    :confirmed_at,
    :reset_sent_at,
    :role,
    :sessions,
    :memberships,
    :teams,
    :ssh_public_keys
  ]

  def fixture(:user, attrs \\ @valid_user) do
    {:ok, %{user: user}} = Accounts.register_user(attrs)
    user
  end

  describe "read user data" do
    test "list_users/1 returns all users" do
      user = fixture(:user)
      assert Accounts.list_users() != []
      [current_user] = Accounts.list_users()

      assert assert Map.take(user, @user_attrs) == Map.take(current_user, @user_attrs)
    end

    test "get returns the user with given id" do
      user = fixture(:user)
      assert Map.take(user, @user_attrs) == Map.take(Accounts.get_user(user.id), @user_attrs)
    end

    test "change_user/1 returns a user changeset" do
      user = fixture(:user)
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "write user data" do
    test "register_user/1 with valid data creates a user" do
      assert {:ok, %{user: %User{} = user}} = Accounts.register_user(@valid_user)
      assert user.email == "fred@example.com"
      assert user.role == "User"
    end

    test "register_user/1 with valid data creates a user with team" do
      assert {:ok, %{user: %User{} = user}} = Accounts.register_user(@valid_user)

      %User{teams: [team | _]} = Accounts.get_user(user.id, [:teams])
      assert team.name == "company"
      assert user.email == "fred@example.com"
      assert user.role == "User"
    end

    test "register_user/1 returns error if user already exists" do
      _user = fixture(:user)
      assert {:error, :user, %{errors: errors}, _} = Accounts.register_user(@valid_user)
      assert Enum.count(errors) > 0
    end

    test "register_user/1 returns error if team already exists" do
      _user = fixture(:user)

      new_user = %{
        user_email: "fred1@example.com",
        user_password: "reallyHard2gue$$",
        user_name: "fred1",
        team_name: "company",
        team_namespace: "company"
      }

      assert {:error, :team, %{errors: errors}, _} = Accounts.register_user(new_user)
      assert Enum.count(errors) > 0
    end

    test "register_user/1 with invalid namespace returns multi errors" do
      fixture(:user)

      assert {
               :error,
               :registration,
               %{errors: [team_namespace: {"can't be blank", [validation: :required]}]},
               _
             } = Accounts.register_user(@invalid_namespace)
    end

    test "register_user/1 with invalid data returns mulit errors" do
      assert {:error, :registration, %{errors: errors}, _} = Accounts.register_user(@invalid_user)

      assert Enum.count(errors) > 0
    end

    test "update_user/2 with valid data updates the user" do
      user = fixture(:user)
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "frederick@example.com"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = fixture(:user)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_update_attrs)
      assert Map.take(user, @user_attrs) == Map.take(Accounts.get_user(user.id), @user_attrs)
    end

    test "update password changes the stored hash" do
      %{password_hash: stored_hash} = user = fixture(:user)
      attrs = %{password: "CN8W6kpb"}
      {:ok, %{password_hash: hash}} = Accounts.update_password(user, attrs)
      assert hash != stored_hash
    end

    test "update_password with weak password fails" do
      user = fixture(:user)
      attrs = %{password: "pass"}
      assert {:error, %Ecto.Changeset{}} = Accounts.update_password(user, attrs)
    end
  end

  #  describe "delete user data" do
  #    test "delete_user/1 deletes the user" do
  #      user = fixture(:user)
  #      assert {:ok, %User{}} = Accounts.delete_user(user)
  #      refute Accounts.get_user(user.id)
  #    end
  #  end
end
