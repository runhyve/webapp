defmodule WebappWeb.Router do
  use WebappWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_auth do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Phauxth.Remember, create_session_func: &WebappWeb.Accounts.Utils.create_session/1
    plug WebappWeb.Authenticate
    plug WebappWeb.TeamContext
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug WebappWeb.HypervisorTokenAuth
  end

  scope "/api/v1", WebappWeb do
    pipe_through :api

    resources "/distributions", DistributionController, except: [:new, :edit]
  end

  scope "/", WebappWeb do
    pipe_through :browser

    get "/health", PageController, :health
  end

  scope "/", WebappWeb do
    pipe_through :browser_auth

    get "/", PageController, :index

    resources "/users", UserController, except: [:delete]
    get "/users/:id/teams", UserController, :teams

    resources "/user/keys", SSHPublicKeyController, except: [:edit]

    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/user/confirm", UserController, :confirm
    resources "/user/password_resets", PasswordResetController, only: [:new, :create]
    get "/user/password_resets/edit", PasswordResetController, :edit
    put "/user/password_resets/update", PasswordResetController, :update

    resources "/teams", TeamController, except: [:delete] do
      resources "/members", MemberController, except: [:index]
    end

    get "/ip_pools/new", IpPoolController, :new

    # Machine
    resources "/machines", MachineController, except: [:new, :create]
    get "/machines/:id/console", MachineController, :console
    post "/machines/:id/start", MachineController, :start
    post "/machines/:id/stop", MachineController, :stop
    post "/machines/:id/poweroff", MachineController, :poweroff
    get "/hypervisors/:hypervisor_id/machines/new", MachineController, :new
    post "/hypervisors/:hypervisor_id/machines/create", MachineController, :create
  end

  scope "/admin", WebappWeb.Admin, as: :admin do
    pipe_through :browser_auth

    resources "/hypervisors", HypervisorController do
      resources "/networks", NetworkController, only: [:new, :create, :index]
      resources "/machines", MachineController, only: [:new, :create, :index]
    end

    resources "/machines", MachineController, only: [:index]
    resources "/plans", PlanController
    resources "/networks", NetworkController, except: [:new, :create, :index]
    resources "/ip_pools", Ip_poolController, except: [:edit, :update, :delete]
    resources "/users", UserController, only: [:index]
    resources "/teams", TeamController, only: [:index]
  end

  scope "/" do
    pipe_through :browser

    # Useful development tools.
    if Mix.env() == :dev do
      forward "/dev/mailbox", Bamboo.SentEmailViewerPlug
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", WebappWeb do
  #   pipe_through :api
  # end
end
