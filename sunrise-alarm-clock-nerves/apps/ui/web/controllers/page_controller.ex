defmodule Ui.PageController do
  use Ui.Web, :controller
  alias Ui.Settings, as: UiSettings

  def index conn, _params do
    render conn, "index.html", settings: get_settings
  end

  def create conn, params do
    settings = params["settings"]
    Settings.put :alarm_active, settings["alarm_active"] == "true"
    Settings.put :alarm_hour, String.to_integer(settings["alarm_time"]["hour"])
    Settings.put :alarm_minute, String.to_integer(settings["alarm_time"]["minute"])
    Settings.put :dimmer_advance, String.to_integer(settings["dimmer_advance"])
    Settings.put :max_brightness, String.to_integer(settings["max_brightness"])
    Settings.put :time_zone, String.to_integer(settings["time_zone"])
    render conn, "index.html", settings: get_settings
  end

  defp get_settings do
    UiSettings.changeset %UiSettings{
      alarm_active: Settings.get(:alarm_active),
      alarm_time: (({:ok, time} = Time.new(Settings.get(:alarm_hour), Settings.get(:alarm_minute), 0); time)),
      dimmer_advance: Settings.get(:dimmer_advance),
      max_brightness: Settings.get(:max_brightness),
      time_zone: Settings.get(:time_zone)
    }
  end
end
