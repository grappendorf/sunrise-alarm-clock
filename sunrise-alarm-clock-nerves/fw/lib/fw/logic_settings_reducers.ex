defmodule Fw.LogicSettingsReducers do
  alias Fw.Settings

  def reduce state, :reload_settings do
    %{state |
      alarm_active: Settings.get(:alarm_active),
      alarm_hour: Settings.get(:alarm_hour),
      alarm_minute: Settings.get(:alarm_minute),
      sunrise_duration: Settings.get(:sunrise_duration),
      max_brightness: Settings.get(:max_brightness),
      time_zone: Settings.get(:time_zone)}
  end

  def reduce(state, _) do
    state
  end
end
