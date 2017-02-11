defmodule Sim.Settings do
  use ExActor.GenServer, export: :settings

  @default_values %{
    alarm_active: false,
    alarm_hour: 0,
    alarm_minute: 0,
    sunrise_duration: 15,
    max_brightness: 0,
    time_zone: 1}

  defstart start_link do
    initial_state %{}
  end

  defcast put(key, value), state: state do
    new_state state |> Map.put(key, value)
  end

  defcall get(key), state: state do
    reply Map.get(state, key, @default_values[key])
  end
end
