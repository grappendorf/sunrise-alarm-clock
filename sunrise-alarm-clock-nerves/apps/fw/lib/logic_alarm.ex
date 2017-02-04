defmodule LogicAlarm do
  use ExActor.GenServer, export: :logic_alarm

  @clock_interval 1 * 1000
  @alarm_check_interval 60 * 1000

  defstart start_link do
    state = %{
      fsm: LogicAlarmFsm.new,
    }
    |> schedule_clock_tick
    |> schedule_alarm_check
    initial_state state
  end

  defcast touched, state: state = %{fsm: fsm} do
    new_state %{state | fsm: LogicAlarmFsm.touched(fsm)}
    noreply()
  end

  defhandleinfo :clock_tick, state: state = %{fsm: fsm} do
    new_state state |> schedule_clock_tick |> Map.put(:fsm, LogicAlarmFsm.clock_tick(fsm))
  end

  defhandleinfo :alarm_check, state: state = %{fsm: fsm} do
    new_state state |> schedule_alarm_check |> Map.put(:fsm, LogicAlarmFsm.alarm_check(fsm))
  end

  defp schedule_clock_tick state do
    Process.send_after self(), :clock_tick, @clock_interval
    state
  end

  defp schedule_alarm_check state do
    Process.send_after self(), :alarm_check, @alarm_check_interval
    state
  end
end
