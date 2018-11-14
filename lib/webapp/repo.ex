defmodule Webapp.Repo do
  use Ecto.Repo,
    otp_app: :webapp,
    adapter: Ecto.Adapters.Postgres
end
