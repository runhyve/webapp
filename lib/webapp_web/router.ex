defmodule WebappWeb.Router do
  use WebappWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WebappWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/hypervisors", HypervisorController

    resources "/machines", MachineController
    get "/machines/:id/console", MachineController, :console
    post "/machines/:id/start", MachineController, :start
    post "/machines/:id/stop", MachineController, :stop
    post "/machines/:id/poweroff", MachineController, :poweroff

    resources "/plans", PlanController
  end

  # Other scopes may use custom stacks.
  # scope "/api", WebappWeb do
  #   pipe_through :api
  # end
end
