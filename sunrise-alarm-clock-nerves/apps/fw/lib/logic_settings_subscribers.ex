defmodule LogicSettingsSubscribers do
  def update new, old do
    put_if_changed :alarm_active, new, old
    put_if_changed :alarm_hour, new, old
    put_if_changed :alarm_minute, new, old
    put_if_changed :sunrise_duration, new, old
    put_if_changed :max_brightness, new, old
    put_if_changed :time_zone, new, old
  end

  defp put_if_changed key, new, old do
    if new[key] != old[key], do: Settings.put(key, new[key])
  end
end
