defmodule Webapp.Notifications.Notifications do
  @moduledoc """
  Notifications helper functions
  """

  @doc """
  Send notifications about machine's events.
  Use publish_notification/5 for Multi.run/5; publish_notification/3 to call directly
  """

  def publish(_repo, _changes, severity, msg) do
    WebappWeb.Endpoint.broadcast("events", "events", %{severity: severity, msg: msg})
    {:ok, :broadcasted}
  end

  def publish(severity, msg) do
    WebappWeb.Endpoint.broadcast("events", "events", %{severity: severity, msg: msg})
    {:ok, :broadcasted}
  end
end