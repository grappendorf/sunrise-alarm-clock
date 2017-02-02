defmodule LogicAlarmFsm do
  use Fsm, initial_state: :idle, initial_data: %{brightness: 0, brightness_delta: 0}

  state idle do
    on enter, data: data do
      Leds.light 0
      transition %{data | brightness: 0}
    end

    event alarm_check do
      now = Timex.now Settings.get :time_zone
      alarm_time = now
        |> Timex.set(hour: Settings.get(:alarm_hour), minute: Settings.get(:alarm_minute), second: 0)
        |> Timex.shift(minutes: -1 * Settings.get(:dimmer_advance))
      alarm_time_later = alarm_time |> Timex.shift(minutes: 2)
      if Settings.get(:alarm_active) && Timex.between? now, alarm_time, alarm_time_later do
        transition :sunrise
      end
    end
  end

  state sunrise do
    on enter, data: data do
      transition %{data | brightness_delta: get_brightness_delta()}
    end

    event clock_tick, data: data = %{brightness: brightness, brightness_delta: delta} do
      new_brightness = min(brightness + delta, 255)
      Leds.light round(new_brightness)
      if new_brightness >= 255 do
        transition :alarm
      else
        transition %{data | brightness: new_brightness}
      end
    end

    event touched do
      transition :idle
    end

    defp get_brightness_delta do
      max_brightness = 16 * Settings.get(:max_brightness) + 15
      max_brightness / (Settings.get(:dimmer_advance) * 60)
    end
  end

  state alarm do
    event touched do
      transition :idle
    end
  end

  event _ do
  end
end
