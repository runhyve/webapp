defmodule WebappWeb.SSHPublicKeyController do
  use WebappWeb, :controller

  alias Webapp.Accounts

  alias Webapp.Accounts.{
    User,
    Team,
    SSHPublicKey
  }

  plug :load_and_authorize_resource,
    model: SSHPublicKey,
    non_id_actions: [:index, :create, :new]

  def index(%Conn{assigns: %{current_user: user}} = conn, _params) do
    ssh_public_keys = Accounts.list_user_ssh_public_keys(user)
    render(conn, "index.html", ssh_public_keys: ssh_public_keys)
  end

  def new(conn, _params) do
    changeset = Accounts.change_ssh_public_key(%SSHPublicKey{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"ssh_public_key" => ssh_public_key_params}) do
    case Accounts.create_ssh_public_key(conn.assigns.current_user, ssh_public_key_params) do
      {:ok, ssh_public_key} ->
        conn
        |> put_flash(:info, "Ssh public key created successfully.")
        |> redirect(to: Routes.ssh_public_key_path(conn, :show, ssh_public_key))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, _params) do
    ssh_public_key = conn.assigns[:ssh_public_key]
    render(conn, "show.html", ssh_public_key: ssh_public_key)
  end

  def delete(conn, _params) do
    ssh_public_key = conn.assigns[:ssh_public_key]
    {:ok, _ssh_public_key} = Accounts.delete_ssh_public_key(ssh_public_key)

    conn
    |> put_flash(:info, "Ssh public key deleted successfully.")
    |> redirect(to: Routes.ssh_public_key_path(conn, :index))
  end
end
