defmodule Fw.LogicAlarmSubscribers do
  alias Fw.Leds

  def update(%{alarm: :idle}, %{alarm: old_alarm}) when old_alarm != :idle do
    Leds.light 0
  end

  def update state = %{alarm: :sunrise}, old do
    if state.brightness != old.brightness do
      Leds.light round(state.brightness)
    end
  end

  def update(_, _), do: nil
end
