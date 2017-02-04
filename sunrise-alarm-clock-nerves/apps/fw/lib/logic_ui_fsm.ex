defmodule LogicUiFsm do
  import ExPrintf
  use Fsm, initial_state: :clock

  state clock do
    on enter do
      Lcd.clear
      update_clock()
    end

    event clock_tick do
      update_clock()
    end

    event button_1 do
      transition :set_alarm_active
    end

    event button_2 do
      transition :about
    end

    defp update_clock do
      %DateTime{hour: hour, minute: minute, second: second} = Timex.now Settings.get :time_zone
      Lcd.home
      Lcd.print sprintf("    %02d:%02d:%02d    ", [hour, minute, second])
      Lcd.goto 0, 1
      if Settings.get :alarm_active do
        Lcd.print "       \x01\x01       "
      else
        Lcd.print "                "
      end
    end
  end

  state set_alarm_active do
    on enter do
      Lcd.clear
      Lcd.print "Alarm Active"
      update_alarm_active()
    end

    event button_1 do
      transition :set_alarm_time_hour
    end

    event button_3 do
      Settings.put :alarm_active, !Settings.get(:alarm_active)
      update_alarm_active()
    end

    event button_4 do
      Settings.put :alarm_active, !Settings.get(:alarm_active)
      update_alarm_active()
    end

    defp update_alarm_active do
      Lcd.goto 0, 1
      Lcd.draw_checkbox Settings.get(:alarm_active)
    end
  end

  state set_alarm_time_hour do
    on enter do
      Lcd.clear
      Lcd.print "Alarm Time"
      Lcd.goto 0, 1
      Lcd.draw_time Settings.get(:alarm_hour), Settings.get(:alarm_minute)
      Lcd.cursor :blink
      update_alarm_time_hour()
    end

    on leave do
      Lcd.cursor :off
    end

    event button_1 do
      transition :set_alarm_time_minute
    end

    event button_3 do
      Settings.put :alarm_hour,
        (Settings.get(:alarm_hour) |> Kernel.+(1) |> Kernel.rem(24))
      update_alarm_time_hour()
    end

    event button_4 do
      Settings.put :alarm_hour,
        (Settings.get(:alarm_hour) |> Kernel.+(23) |> Kernel.rem(24))
      update_alarm_time_hour()
    end

    defp update_alarm_time_hour do
      Lcd.goto 0, 1
      Lcd.print sprintf("%02d", [Settings.get :alarm_hour])
      Lcd.goto 1, 1
    end
  end

  state set_alarm_time_minute do
    on enter do
      Lcd.clear
      Lcd.print "Alarm Time"
      Lcd.goto 0, 1
      Lcd.draw_time Settings.get(:alarm_hour), Settings.get(:alarm_minute)
      Lcd.cursor :blink
      update_alarm_time_minute()
    end

    on leave do
      Lcd.cursor :off
    end

    event button_1 do
      transition :set_dimmer_advance
    end

    event button_3 do
      Settings.put :alarm_minute,
        (Settings.get(:alarm_minute) |> Kernel.+(1) |> Kernel.rem(60))
      update_alarm_time_minute()
    end

    event button_4 do
      Settings.put :alarm_minute,
        (Settings.get(:alarm_minute) |> Kernel.+(59) |> Kernel.rem(60))
      update_alarm_time_minute()
    end

    defp update_alarm_time_minute do
      Lcd.goto 3, 1
      Lcd.print sprintf("%02d", [Settings.get :alarm_minute])
      Lcd.goto 4, 1
    end
  end

  state set_dimmer_advance do
    on enter do
      Lcd.clear
      Lcd.print "Dimmer Advance"
      update_dimmer_advance()
    end

    event button_1 do
      transition :set_max_brightness
    end

    event button_3 do
      value = (Settings.get :dimmer_advance) + 15
      if value <= 60 do
        Settings.put :dimmer_advance, value
        update_dimmer_advance()
      end
    end

    event button_4 do
      value = (Settings.get :dimmer_advance) - 15
      if value >= 15 do
        Settings.put :dimmer_advance, value
        update_dimmer_advance()
      end
    end

    defp update_dimmer_advance do
      Lcd.goto 0, 1
      Lcd.print sprintf("%02d minutes", [Settings.get(:dimmer_advance)])
    end
  end

  state set_max_brightness do
    on enter do
      Lcd.clear
      Lcd.print "Max Brightness"
      update_max_brightness()
    end

    on leave do
      Leds.light 0
    end

    event button_1 do
      transition :set_time_zone
    end

    event button_3 do
      value = (Settings.get :max_brightness) + 1
      if value <= 15 do
        Settings.put :max_brightness, value
        update_max_brightness()
      end
    end

    event button_4 do
      value = (Settings.get :max_brightness) - 1
      if value >= 0 do
        Settings.put :max_brightness, value
        update_max_brightness()
      end
    end

    defp update_max_brightness do
      Lcd.goto 0, 1
      Lcd.draw_bar Settings.get(:max_brightness)
      Leds.light Settings.get(:max_brightness) * 16 + 15
    end
  end

  state set_time_zone do
    on enter do
      Lcd.clear
      Lcd.print "Time Zone"
      update_time_zone()
    end

    event button_1 do
      transition :clock
    end

    event button_3 do
      Settings.put :time_zone,
        (Settings.get(:time_zone) |> Kernel.+(12) |> Kernel.rem(24)) |> Kernel.-(11)
      update_time_zone()
    end

    event button_4 do
      Settings.put :time_zone,
        (Settings.get(:time_zone) |> Kernel.+(34) |> Kernel.rem(24)) |> Kernel.-(11)
      update_time_zone()
    end

    defp update_time_zone do
      Lcd.goto 0, 1
      Lcd.print sprintf("%d  ", [Settings.get(:time_zone)])
    end
  end

  state about do
    on enter do
      Lcd.clear
      Lcd.print " Sunrise Alarm  "
      Lcd.goto 0, 1
      Lcd.print " Version 0.1.0  "
    end

    event button_1 do
      transition :set_alarm_active
    end

    event button_2 do
      transition :clock
    end
  end

  event button_2, state: state, when: state != :clock do
    transition :clock
  end

  event button_3 do
  end

  event button_4 do
  end

  event touched do
  end

  event idle_timeout do
    transition :clock
  end

  event _ do
  end
end
