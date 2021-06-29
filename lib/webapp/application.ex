defmodule Webapp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Webapp.Repo,
      # Start the endpoint when the application starts
      WebappWeb.Endpoint,
      {Phoenix.PubSub, [name: Webapp.PubSub, adapter: Phoenix.PubSub.PG2]},
      # Starts a worker by calling: Webapp.Worker.start_link(arg)
      # {Webapp.Worker, arg},
      Webapp.GuardSupervisor,
      Webapp.NotificationsSupervisor,
      {ConCache,
       [
         name: :rh_cache,
         ttl_check_interval: :timer.seconds(300),
         global_ttl: :timer.seconds(300)
       ]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Webapp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    WebappWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
