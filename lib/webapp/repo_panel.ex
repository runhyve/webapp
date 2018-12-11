defmodule Webapp.RepoPanel do
  use Ecto.Repo,
    otp_app: :webapp,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 12
end
