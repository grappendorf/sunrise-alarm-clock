defmodule Fw.Sim.Leds do
  use ExActor.GenServer, export: :leds

  defstart start_link do
    initial_state %{backlight: :off, light: 0}
  end

  defcall state, state: state do
    reply state
  end

  defcast backlight(:on), state: state do
    new_state %{state| backlight: :on}
  end

  defcast backlight(:off), state: state do
    new_state %{state| backlight: :off}
  end

  defcast light(value), state: state do
    new_state %{state| light: value}
  end
end
