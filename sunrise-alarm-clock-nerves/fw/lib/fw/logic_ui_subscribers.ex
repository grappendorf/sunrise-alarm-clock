defmodule Fw.LogicUiSubscribers do
  import ExPrintf
  alias Fw.{Leds, Lcd}

  def update(%{backlight: new}, %{backlight: old}) when new != old do
    Leds.backlight new
  end

  def update(_, _), do: nil

  def update_page state = %{page: :clock}, old do
    if old.page != :clock do
      Lcd.clear
    end
    %DateTime{hour: hour, minute: minute, second: second} = state.time
    Lcd.goto 4, 0
    Lcd.print sprintf("%02d:%02d:%02d", [hour, minute, second])
    Lcd.goto 7, 1
    if state.alarm_active do
      Lcd.print "\x01\x01"
    else
      Lcd.print "  "
    end
  end

  def update_page state = %{page: :alarm_active}, old do
    if old.page != :alarm_active do
      Lcd.clear
      Lcd.print "Alarm Active"
    end
    if old.page != :alarm_active || state.alarm_active != old.alarm_active do
      Lcd.goto 0, 1
      Lcd.draw_checkbox state.alarm_active
    end
  end

  def update_page state = %{page: :alarm_hour}, old do
    if old.page != :alarm_hour do
      Lcd.clear
      Lcd.print "Alarm Time"
      Lcd.cursor :blink
    end
    if old.page != :alarm_hour ||
        state.alarm_hour != old.alarm_hour || state.alarm_minute != old.alarm_minute do
      Lcd.goto 0, 1
      Lcd.draw_time state.alarm_hour, state.alarm_minute
      Lcd.goto 1, 1
    end
  end

  def update_page state = %{page: :alarm_minute}, old do
    if old.page != :alarm_minute do
      Lcd.clear
      Lcd.print "Alarm Time"
      Lcd.cursor :blink
    end
    if old.page != :alarm_minute ||
        state.alarm_hour != old.alarm_hour || state.alarm_minute != old.alarm_minute do
      Lcd.goto 0, 1
      Lcd.draw_time state.alarm_hour, state.alarm_minute
      Lcd.goto 4, 1
    end
  end

  def update_page state = %{page: :sunrise_duration}, old do
    if old.page != :sunrise_duration do
      Lcd.clear
      Lcd.print "Sunrise Duration"
    end
    if old.page != :sunrise_duration || state.sunrise_duration != old.sunrise_duration do
      Lcd.goto 0, 1
      Lcd.print sprintf("%02d minutes", [state.sunrise_duration])
    end
  end

  def update_page state = %{page: :max_brightness}, old do
    if old.page != :max_brightness do
      Lcd.clear
      Lcd.print "Max Brightness"
    end
    if old.page != :max_brightness || state.max_brightness != old.max_brightness do
      Lcd.goto 0, 1
      Lcd.draw_bar state.max_brightness
      Leds.light state.max_brightness * 16 + 15
    end
  end

  def update_page state = %{page: :time_zone}, old do
    if old.page != :time_zone do
      Lcd.clear
      Lcd.print "Time Zone"
    end
    if old.page != :time_zone || state.time_zone != old.time_zone do
      Lcd.goto 0, 1
      Lcd.print sprintf("%d  ", [state.time_zone])
    end
  end

  def update_page %{page: :about}, old do
    if old.page != :about do
      Lcd.clear
      Lcd.print " Sunrise Alarm  "
      Lcd.goto 0, 1
      Lcd.print sprintf(" Version %5s  ", [Application.get_env(:fw, :misc)[:version]])
    end
  end

  def update_page(_, _), do: nil

  def leave_page(%{page: new_page}, %{page: :alarm_hour}) when new_page != :alarm_hour do
    Lcd.cursor :off
  end

  def leave_page(%{page: new_page}, %{page: :alarm_minute}) when new_page != :alarm_minute do
    Lcd.cursor :off
  end

  def leave_page(%{page: new_page}, %{page: :max_brightness}) when new_page != :max_brightness do
    Leds.light 0
  end

  def leave_page(_, _), do: nil
end
