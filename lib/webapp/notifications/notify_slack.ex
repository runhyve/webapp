defmodule Webapp.Notifications.NotifySlack do
  use GenServer
  require Logger
  alias Phoenix.Socket.Broadcast

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    Logger.info("Starting #{__MODULE__} module. Subscribing to machines topic.")
    WebappWeb.Endpoint.subscribe("machines")
    {:ok, %{}}
  end

  def handle_call(:get, _, state) do
    {:reply, state, state}
  end

  def handle_info(%Broadcast{topic: _, event: event, payload: payload}, socket) do
    slack_message = "#{payload.severity}: #{payload.msg}"
    Logger.info("[NotifySlack] Sending Slack notification: #{slack_message}")
    send(slack_message)

    {:noreply, []}
  end

  defp gen_slack_text(msg, username, channel) do
      """
      {"username": "#{username}",
      "channel": "#{channel}",
      "text": "#{msg}",
      "icon_emoji": ":bee:"}
      """
  end

  defp get_slack_config() do
      url = Application.get_env(:webapp, Webapp.Notifications)[:slack_webhook_url]
      username = Application.get_env(:webapp, Webapp.Notifications)[:slack_username]
      channel = Application.get_env(:webapp, Webapp.Notifications)[:slack_channel]
      %{url: url, username: username, channel: channel}
  end

  defp send(msg) do
    slack_config = get_slack_config()
    HTTPoison.post(slack_config[:url], gen_slack_text(msg, slack_config[:username], slack_config[:channel]))
  end
end
