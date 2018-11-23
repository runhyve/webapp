defmodule WebappWeb.AuthCase do
  use Phoenix.ConnTest

  import Ecto.Changeset

  alias Webapp.{Accounts, Repo, Sessions}
  alias WebappWeb.Auth.Token

  def add_user(email) do
    name =
      email
      |> String.split("@")
      |> hd()

    user = %{
      email: email,
      password: "reallyHard2gue$$",
      name: name,
      namespace: %{namespace: name}
    }

    {:ok, user} = Accounts.create_user(user)
    user
  end

  def gen_key(email), do: Token.sign(%{"email" => email})

  def add_user_confirmed(email) do
    email
    |> add_user()
    |> change(%{confirmed_at: now()})
    |> Repo.update!()
  end

  def add_reset_user(email) do
    email
    |> add_user()
    |> change(%{confirmed_at: now()})
    |> change(%{reset_sent_at: now()})
    |> Repo.update!()
  end

  def add_session(conn, user) do
    {:ok, %{id: session_id}} = Sessions.create_session(%{user_id: user.id})

    conn
    |> put_session(:phauxth_session_id, session_id)
    |> configure_session(renew: true)
  end

  defp now do
    DateTime.utc_now() |> DateTime.truncate(:second)
  end
end
