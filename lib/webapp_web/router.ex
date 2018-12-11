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

    resources "/hypervisors", HypervisorController do
      resources "/networks", NetworkController, only: [:new, :create, :index]
      resources "/machines", MachineController, only: [:new, :create, :index]
    end

    # get "/hypervisor/:id/networks", HypervisorController, :index_networks

    resources "/machines", MachineController, except: [:new, :create]
    get "/machines/:id/console", MachineController, :console
    post "/machines/:id/start", MachineController, :start
    post "/machines/:id/stop", MachineController, :stop
    post "/machines/:id/poweroff", MachineController, :poweroff

    resources "/plans", PlanController

    resources "/networks", NetworkController, except: [:new, :create, :index]

    get "/dns", DNSController, :index
    get "/dns/:id", DNSController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", WebappWeb do
  #   pipe_through :api
  # end
end
