defmodule WebappWeb.ViewHelpers do
  alias WebappWeb.Router.Helpers, as: Routes

  alias Webapp.{
    Accounts.Team
  }

  def team_path(helper, %Plug.Conn{assigns: %{team: %Team{} = team}} = conn, action, opts \\ []) do
    path = apply(Routes, helper, [conn, action, opts])
    "/" <> team.namespace <> path
  end

  def team_path(helper, conn, action, opts) do
    apply(Routes, helper, [conn, action, opts])
  end
end