defmodule Settings do
  use ExActor.GenServer, export: :settings

  @default_values %{
    alarm_active: false,
    alarm_hour: 0,
    alarm_minute: 0,
    sunrise_duration: 15,
    max_brightness: 0,
    time_zone: 1}

  defstart start_link do
    :ok = PersistentStorage.setup path: "/root/settings"
    initial_state %{}
  end

  defcast put(key, value) do
    PersistentStorage.put key, value
    noreply()
  end

  defcall get(key) do
    reply PersistentStorage.get(key, @default_values[key])
  end
end
