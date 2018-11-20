defmodule Webapp.AccountsUserTest do
  use Webapp.DataCase

  alias Webapp.Accounts
  alias Webapp.Accounts.User

  @valid_user %{
    email: "fred@example.com",
    password: "reallyHard2gue$$",
    name: "fred",
    namespace: %{namespace: "company"}
  }
  @invalid_namespace %{
    email: "garry@example.com",
    password: "reallyHard2gue$$",
    name: "garry",
    namespace: %{namespace: "company"}
  }
  @update_attrs %{email: "frederick@example.com", name: "frederick"}
  @invalid_user %{email: "", password: ""}

  def fixture(:user, attrs \\ @valid_user) do
    {:ok, user} = Accounts.create_user(attrs)
    user
  end

  describe "read user data" do
    test "list_users/1 returns all users" do
      user = fixture(:user)
      assert Accounts.list_users([:namespace]) == [user]
    end

    test "get returns the user with given id" do
      user = fixture(:user)
      assert Accounts.get_user(user.id) == user
    end

    test "change_user/1 returns a user changeset" do
      user = fixture(:user)
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "write user data" do
    test "create_user/1 with valid data creates a user with namespace" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_user)
      assert user.email == "fred@example.com"
      assert user.namespace.namespace == "company"
    end

    test "create_user/1 with invalid namespace returns error changeset" do
      fixture(:user)
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_namespace)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_user)
    end

    test "update_user/2 with valid data updates the user" do
      user = fixture(:user)
      # Ecto.Changeset.cast_assoc expects to have id key of related namespace on_update.
      @update_attrs =
        Map.merge(@update_attrs, %{
          namespace: %{namespace: "frederick-ltd", id: user.namespace.id}
        })

      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "frederick@example.com"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = fixture(:user)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_user)
      assert user == Accounts.get_user(user.id)
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

  describe "delete user data" do
    test "delete_user/1 deletes the user" do
      user = fixture(:user)
      assert {:ok, %User{}} = Accounts.delete_user(user)
      refute Accounts.get_user(user.id)
    end
  end
end
