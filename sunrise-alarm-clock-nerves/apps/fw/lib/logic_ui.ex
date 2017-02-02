defmodule LogicUi do
  use GenServer

  @clock_interval 1 * 1000
  @idle_timout Application.get_env(:fw, :misc)[:display_timeout] * 1000

  def start_link do
    GenServer.start_link __MODULE__, nil, name: :logic_ui
  end

  def init _ do
    state = %{
      fsm: LogicUiFsm.new,
      idle_timer: nil
    }
    |> _schedule_clock_tick
    |> _schedule_idle_timeout
    {:ok, state}
  end

  def button_pressed num do
    Leds.backlight :on
    GenServer.cast :logic_ui, {:button, num}
  end

  def touched do
    Leds.backlight :on
    GenServer.cast :logic_ui, :touched
  end

  def handle_cast {:button, 1}, state = %{fsm: fsm} do
    state = _schedule_idle_timeout state
    {:noreply, %{state | fsm: LogicUiFsm.button_1 fsm}}
  end

  def handle_cast {:button, 2}, state = %{fsm: fsm} do
    state = _schedule_idle_timeout state
    {:noreply, %{state | fsm: LogicUiFsm.button_2 fsm}}
  end

  def handle_cast {:button, 3}, state = %{fsm: fsm} do
    state = _schedule_idle_timeout state
    {:noreply, %{state | fsm: LogicUiFsm.button_3 fsm}}
  end

  def handle_cast {:button, 4}, state = %{fsm: fsm} do
    state = _schedule_idle_timeout state
    {:noreply, %{state | fsm: LogicUiFsm.button_4 fsm}}
  end

  def handle_cast :touched, state = %{fsm: fsm} do
    state = _schedule_idle_timeout state
    {:noreply, %{state | fsm: LogicUiFsm.touched(fsm)}}
  end

  def handle_info :clock_tick, state = %{fsm: fsm} do
    state = _schedule_clock_tick state
    {:noreply, %{state | fsm: LogicUiFsm.clock_tick(fsm)}}
  end

  def handle_info :idle_timeout, state = %{fsm: fsm} do
    Leds.backlight :off
    {:noreply, %{state | fsm: LogicUiFsm.idle_timeout(fsm), idle_timer: nil}}
  end

  defp _schedule_clock_tick state do
    Process.send_after self(), :clock_tick, @clock_interval
    state
  end

  defp _schedule_idle_timeout state = %{idle_timer: timer} do
    if timer, do: Process.cancel_timer timer
    timer = Process.send_after self(), :idle_timeout, @idle_timout
    %{state | idle_timer: timer}
  end
end
