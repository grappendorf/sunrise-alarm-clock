defmodule LogicAlarm do
  use GenServer

  @clock_interval 1 * 1000
  @alarm_check_interval 60 * 1000

  def start_link do
    GenServer.start_link __MODULE__, nil, name: :logic_alarm
  end

  def init _ do
    state = %{
      fsm: LogicAlarmFsm.new,
    }
    |> _schedule_clock_tick
    |> _schedule_alarm_check
    {:ok, state}
  end

  def touched do
    GenServer.cast :logic_alarm, :touched
  end

  def handle_cast :touched, state = %{fsm: fsm} do
    {:noreply, %{state | fsm: LogicAlarmFsm.touched(fsm)}}
  end

  def handle_info :clock_tick, state = %{fsm: fsm} do
    state = _schedule_clock_tick state
    {:noreply, %{state | fsm: LogicAlarmFsm.clock_tick(fsm)}}
  end

  def handle_info :alarm_check, state = %{fsm: fsm} do
    state = _schedule_alarm_check state
    {:noreply, %{state | fsm: LogicAlarmFsm.alarm_check fsm}}
  end

  defp _schedule_clock_tick state do
    Process.send_after self(), :clock_tick, @clock_interval
    state
  end

  defp _schedule_alarm_check state do
    Process.send_after self(), :alarm_check, @alarm_check_interval
    state
  end
end
