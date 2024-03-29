defmodule WebappWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use WebappWeb, :controller
      use WebappWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: WebappWeb

      import Plug.Conn
      import WebappWeb.Gettext
      import Canary.Plugs
      alias WebappWeb.Router.Helpers, as: Routes
      import WebappWeb.Authorize
      alias Plug.Conn

      import WebappWeb.ViewHelpers, only: [team_path: 3, team_path: 4]
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/webapp_web/templates", pattern: "**/*", namespace: WebappWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import WebappWeb.ErrorHelpers
      import WebappWeb.Gettext
      alias WebappWeb.Router.Helpers, as: Routes

      import Canada.Can, only: [can?: 3]
      import PhoenixActiveLink
      import WebappWeb.ViewHelpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import WebappWeb.Gettext
    end
  end

  def model do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
    end
  end

  def email do
    quote do
      import Bamboo.Email
      alias Webapp.Mailer
      use Bamboo.Phoenix, view: WebappWeb.UserView

      alias WebappWeb.Router.Helpers, as: Routes
      alias WebappWeb.Endpoint
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
