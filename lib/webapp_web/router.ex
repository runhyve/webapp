defmodule WebappWeb.Router do
  use WebappWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Phauxth.Authenticate
    plug Phauxth.Remember
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WebappWeb do
    pipe_through :browser

    get "/", PageController, :index

    resources "/users", UserController
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/confirm", ConfirmController, :index
    resources "/password_resets", PasswordResetController, only: [:new, :create]
    get "/password_resets/edit", PasswordResetController, :edit
    put "/password_resets/update", PasswordResetController, :update

    resources "/groups", GroupController

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
  end

  scope "/" do
    pipe_through :browser

    # Useful development tools.
    if Mix.env == :dev do
      forward "/dev/mailbox", Bamboo.SentEmailViewerPlug
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", WebappWeb do
  #   pipe_through :api
  # end
end
