defmodule LogicUi do
  use ExActor.GenServer, export: :logic_ui

  @clock_interval 1 * 1000
  @idle_timout Application.get_env(:fw, :misc)[:display_timeout] * 1000

  defstart start_link do
    state = %{
      fsm: LogicUiFsm.new,
      idle_timer: nil
    }
    |> schedule_clock_tick
    |> schedule_idle_timeout
    initial_state state
  end

  defcast button_pressed(1), state: state = %{fsm: fsm} do
    Leds.backlight :on
    new_state state |> schedule_idle_timeout |> Map.put(:fsm, LogicUiFsm.button_1 fsm)
  end

  defcast button_pressed(2), state: state = %{fsm: fsm} do
    Leds.backlight :on
    new_state state |> schedule_idle_timeout |> Map.put(:fsm, LogicUiFsm.button_2 fsm)
  end

  defcast button_pressed(3), state: state = %{fsm: fsm} do
    Leds.backlight :on
    new_state state |> schedule_idle_timeout |> Map.put(:fsm, LogicUiFsm.button_3 fsm)
  end

  defcast button_pressed(4), state: state = %{fsm: fsm} do
    Leds.backlight :on
    new_state state |> schedule_idle_timeout |> Map.put(:fsm, LogicUiFsm.button_4 fsm)
  end

  defcast touched, state: state = %{fsm: fsm} do
    Leds.backlight :on
    new_state state |> schedule_idle_timeout |> Map.put(:fsm, LogicUiFsm.touched fsm)
  end

  defhandleinfo :clock_tick, state: state = %{fsm: fsm} do
    new_state state |> schedule_clock_tick |> Map.put(:fsm, LogicUiFsm.clock_tick fsm)
  end

  defhandleinfo :idle_timeout, state: state = %{fsm: fsm} do
    Leds.backlight :off
    new_state state |> Map.put(:fsm, LogicUiFsm.idle_timeout(fsm)) |> Map.put(:idle_timer, nil)
  end

  defp schedule_clock_tick state do
    Process.send_after self(), :clock_tick, @clock_interval
    state
  end

  defp schedule_idle_timeout state = %{idle_timer: timer} do
    if timer, do: Process.cancel_timer timer
    timer = Process.send_after self(), :idle_timeout, @idle_timout
    %{state | idle_timer: timer}
  end
end
