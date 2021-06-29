# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :webapp,
  ecto_repos: [Webapp.Repo]

# Configures the endpoint
config :webapp, WebappWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "doiKkY1e11RF0fwHberwtJCjErEC24XipePbdyne5HYn5mBvGf+cEQ+ou+CkEpBy",
  render_errors: [view: WebappWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Webapp.PubSub

# Phauxth authentication configuration
config :phauxth,
  user_context: Webapp.Accounts,
  crypto_module: Argon2,
  token_module: WebappWeb.Auth.Token

# Mailer configuration
config :webapp, Webapp.Mailer, adapter: Bamboo.LocalAdapter

config :canary,
  repo: Webapp.Repo,
  unauthorized_handler: {WebappWeb.Accounts.Utils, :handle_unauthorized},
  not_found_handler: {WebappWeb.Accounts.Utils, :handle_not_found}

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix and Ecto
config :phoenix, :json_library, Jason
config :postgrex, :json_library, Jason

config :phoenix_active_link, :defaults,
  wrap_tag: :li,
  class_active: "is-active",
  class_inactive: ""

config :webapp, Webapp.Notifications,
  enabled_modules: [Webapp.Notifications.NotifyConsole],
  slack_webhook_url: "",
  slack_channel: "",
  slack_username: "Runhyve"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
