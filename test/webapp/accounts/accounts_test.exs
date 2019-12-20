defmodule Webapp.AccountsTest do
  use Webapp.DataCase

  alias Webapp.Accounts

  describe "ssh_public_keys" do
    alias Webapp.Accounts.SSHPublicKey

    @create_attrs %{
      ssh_public_key:
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8zjxRY3HmSJ/I6VGvuwEwrQv1hViE9bRx95qz7HR0T7MP10f+X39eKbGF82Nlju1J7u3djgWjNGYp7Yumd3bqbvu8+8Q5yqUYgF2VIDc64Vl0rK4zT6otIKerRcY2vEesZu/pRTZ7VD9dentODLHISRo4+1V+lLEqIFTteBtCxxhJc2g4GVKB2MpL7btZjtqP1X6++8qkg++wXOouNE+3lcgbu6d+SbL9skx3QTO/VwdC+U2yc8lIp2hz79FxUUGIQhV8NuPXp5/sRFGHITkFIu9dxgsqcSoSQQkyBvzd6XCXuwWpAQlmtgsjfYqQdq1/XDL+F2KqH9Vb+rD2dQLT dummy@key",
      title: "some title"
    }
    @invalid_attrs %{ssh_public_key: "invalid public key", title: "some title"}

    @user1 %{
      user_email: "fred@example.com",
      user_password: "reallyHard2gue$$",
      user_name: "fred",
      team_name: "company",
      team_namespace: "company"
    }

    def user_fixture(user) do
      {:ok, user} = Accounts.register_user(user)
      user
    end

    def ssh_public_key_fixture(attrs \\ %{}) do
      %{team: _team, user: user} = user_fixture(@user1)

      {:ok, ssh_public_key} =
        Accounts.create_ssh_public_key(user, Enum.into(attrs, @create_attrs))

      {:ok, ssh_public_key: ssh_public_key, user: user}
    end

    test "list_ssh_public_keys/0 returns all ssh_public_keys" do
      {:ok, ssh_public_key: ssh_public_key, user: _user} = ssh_public_key_fixture()
      assert Accounts.list_ssh_public_keys() == [ssh_public_key]
    end

    test "list_user_ssh_public_keys/0 returns all ssh_public_keys belonging to user" do
      {:ok, ssh_public_key: ssh_public_key, user: user} = ssh_public_key_fixture()
      assert Accounts.list_user_ssh_public_keys(user) == [ssh_public_key]
    end

    test "get_ssh_public_key!/1 returns the ssh_public_key with given id" do
      {:ok, ssh_public_key: ssh_public_key, user: _user} = ssh_public_key_fixture()
      assert Accounts.get_ssh_public_key!(ssh_public_key.id) == ssh_public_key
    end

    test "create_ssh_public_key/1 with valid data creates a ssh_public_key" do
      %{team: _team, user: user} = user_fixture(@user1)

      assert {:ok, %SSHPublicKey{} = ssh_public_key} =
               Accounts.create_ssh_public_key(user, @create_attrs)

      assert ssh_public_key.ssh_public_key ==
               "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8zjxRY3HmSJ/I6VGvuwEwrQv1hViE9bRx95qz7HR0T7MP10f+X39eKbGF82Nlju1J7u3djgWjNGYp7Yumd3bqbvu8+8Q5yqUYgF2VIDc64Vl0rK4zT6otIKerRcY2vEesZu/pRTZ7VD9dentODLHISRo4+1V+lLEqIFTteBtCxxhJc2g4GVKB2MpL7btZjtqP1X6++8qkg++wXOouNE+3lcgbu6d+SbL9skx3QTO/VwdC+U2yc8lIp2hz79FxUUGIQhV8NuPXp5/sRFGHITkFIu9dxgsqcSoSQQkyBvzd6XCXuwWpAQlmtgsjfYqQdq1/XDL+F2KqH9Vb+rD2dQLT dummy@key"

      assert ssh_public_key.title == "some title"
    end

    test "create_ssh_public_key/1 with invalid data returns error changeset" do
      %{team: _team, user: user} = user_fixture(@user1)
      assert {:error, %Ecto.Changeset{}} = Accounts.create_ssh_public_key(user, @invalid_attrs)
    end

    test "delete_ssh_public_key/1 deletes the ssh_public_key" do
      {:ok, ssh_public_key: ssh_public_key, user: _user} = ssh_public_key_fixture()
      assert {:ok, %SSHPublicKey{}} = Accounts.delete_ssh_public_key(ssh_public_key)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_ssh_public_key!(ssh_public_key.id) end
    end
  end
end
