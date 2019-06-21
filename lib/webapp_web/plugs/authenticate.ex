defmodule WebappWeb.Authenticate do
  use Phauxth.Authenticate.Base

  alias Webapp.Repo

  def set_user(nil, conn), do: assign(conn, :current_user, nil)

  def set_user(user, conn) do
    user = user |> Repo.preload([:teams, :ssh_public_keys])
    assign(conn, :current_user, user)
  end
end
