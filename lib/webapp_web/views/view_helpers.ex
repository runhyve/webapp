defmodule WebappWeb.ViewHelpers do
  alias WebappWeb.Router.Helpers, as: Routes

  alias Webapp.{
    Accounts.Team,
    Machines,
    Machines.Machine
  }

  def team_path(
        helper,
        conn,
        action,
        opts \\ []
      )

  def team_path(
        helper,
        %Plug.Conn{assigns: %{current_team: %Team{} = team}} = conn,
        action,
        opts
      ) do
    path = apply(Routes, helper, [conn, action, opts])
    "/" <> team.namespace <> path
  end

  def team_path(helper, conn, action, opts) do
    apply(Routes, helper, [conn, action, opts])
  end

  def action_css_class(%Machine{} = machine, action) do
    case Machines.machine_can_do?(machine, action) do
      false -> "action-#{action} is-hidden"
      _ -> "action-#{action}"
    end
  end

  def action_css_class(_, action), do: "action-#{action}"
end
