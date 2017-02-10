defmodule LogicUiReducers do
  def reduce state, {:backlight, backlight} do
    %{state | backlight: backlight}
  end

  def reduce state = %{page: :boot}, :clock_tick do
    %{state | page: :clock, backlight: :on}
  end

  def reduce state = %{page: :clock}, {:button, 1} do
    %{state | page: :alarm_active}
  end

  def reduce state = %{page: :alarm_active}, {:button, 1} do
    %{state | page: :alarm_hour}
  end

  def reduce state = %{page: :alarm_active}, {:button, 3} do
    %{state | alarm_active: ! state.alarm_active}
  end

  def reduce state = %{page: :alarm_active}, {:button, 4} do
    %{state | alarm_active: ! state.alarm_active}
  end

  def reduce state = %{page: :alarm_hour}, {:button, 1} do
    %{state | page: :alarm_minute}
  end

  def reduce state = %{page: :alarm_hour}, {:button, 3} do
    %{state | alarm_hour: state.alarm_hour |> Kernel.+(23) |> Kernel.rem(24)}
  end

  def reduce state = %{page: :alarm_hour}, {:button, 4} do
    %{state | alarm_hour: state.alarm_hour |> Kernel.+(1) |> Kernel.rem(24)}
  end

  def reduce state = %{page: :alarm_minute}, {:button, 1} do
    %{state | page: :sunrise_duration}
  end

  def reduce state = %{page: :alarm_minute}, {:button, 3} do
    %{state | alarm_minute: state.alarm_minute |> Kernel.+(59) |> Kernel.rem(60)}
  end

  def reduce state = %{page: :alarm_minute}, {:button, 4} do
    %{state | alarm_minute: state.alarm_minute |> Kernel.+(1) |> Kernel.rem(60)}
  end

  def reduce state = %{page: :sunrise_duration}, {:button, 1} do
    %{state | page: :max_brightness}
  end

  def reduce state = %{page: :sunrise_duration}, {:button, 3} do
    %{state | sunrise_duration: state.sunrise_duration |> Kernel.-(15) |> Kernel.max(15)}
  end

  def reduce state = %{page: :sunrise_duration}, {:button, 4} do
    %{state | sunrise_duration: state.sunrise_duration |> Kernel.+(15) |> Kernel.min(60)}
  end

  def reduce state = %{page: :max_brightness}, {:button, 1} do
    %{state | page: :time_zone}
  end

  def reduce state = %{page: :max_brightness}, {:button, 3} do
    %{state | max_brightness: state.max_brightness |> Kernel.-(1) |> Kernel.max(0)}
  end

  def reduce state = %{page: :max_brightness}, {:button, 4} do
    %{state | max_brightness: state.max_brightness |> Kernel.+(1) |> Kernel.min(15)}
  end

  def reduce state = %{page: :time_zone}, {:button, 1} do
    %{state | page: :clock}
  end

  def reduce state = %{page: :time_zone}, {:button, 3} do
    %{state | time_zone: (state.time_zone |> Kernel.+(34) |> Kernel.rem(24)) |> Kernel.-(11)}
  end

  def reduce state = %{page: :time_zone}, {:button, 4} do
    %{state | time_zone: (state.time_zone |> Kernel.+(12) |> Kernel.rem(24)) |> Kernel.-(11)}
  end

  def reduce state = %{page: :clock}, {:button, 2} do
    %{state | page: :about}
  end

  def reduce state = %{page: :about}, {:button, 1} do
    %{state | page: :alarm_active}
  end

  def reduce state, :clock_tick do
    %{state | time: Timex.now state.time_zone}
  end

  def reduce state, {:button, _} do
    %{state | page: :clock}
  end

  def reduce(state, _) do
    state
  end
end
