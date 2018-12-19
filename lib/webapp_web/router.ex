defmodule WebappWeb.Router do
  use WebappWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug WebappWeb.Authenticate
    plug Phauxth.Remember, create_session_func: &WebappWeb.Accounts.Utils.create_session/1
    plug WebappWeb.TeamContext
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WebappWeb do
    pipe_through :browser

    get "/", PageController, :index

    resources "/users", UserController, except: [:delete]
    get "/users/:id/teams", UserController, :teams

    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/user/confirm", UserController, :confirm
    resources "/user/password_resets", PasswordResetController, only: [:new, :create]
    get "/user/password_resets/edit", PasswordResetController, :edit
    put "/user/password_resets/update", PasswordResetController, :update

    resources "/teams", TeamController, except: [:delete] do
      resources "/members", MemberController, except: [:index]
    end

    # Machine
    resources "/machines", MachineController, except: [:new, :create]
    get "/hypervisors/:hypervisor_id/machines/new", MachineController, :new
    post "/hypervisors/:hypervisor_id/machines/create", MachineController, :create
    get "/machines/:id/console", MachineController, :console
    post "/machines/:id/start", MachineController, :start
    post "/machines/:id/stop", MachineController, :stop
    post "/machines/:id/poweroff", MachineController, :poweroff
  end

  scope "/admin", WebappWeb.Admin, as: :admin do
    pipe_through :browser

    resources "/hypervisors", HypervisorController do
      resources "/networks", NetworkController, only: [:new, :create, :index]
      resources "/machines", MachineController, only: [:new, :create, :index]
    end

    resources "/machines", MachineController, only: [:index]
    resources "/plans", PlanController
    resources "/networks", NetworkController, except: [:new, :create, :index]
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
