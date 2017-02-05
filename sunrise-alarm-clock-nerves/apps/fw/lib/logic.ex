defmodule Logic do
  use ExActor.GenServer, export: :logic

  @clock_interval 1 * 1000
  @alarm_check_interval 30 * 1000
  @idle_timout Application.get_env(:fw, :misc)[:display_timeout] * 1000

  defstart start_link do
    store = create_store() |> add_store_reducers |> add_store_subscribers
    state = create_state(store) |> init_schedules
    initial_state state
  end

  defcast dispatch(action = {:button, _}), state: state = %{store: store} do
    new_store = store |> Store.dispatch({:backlight, :on}) |> Store.dispatch(action)
    new_state state |> schedule_idle_timeout |> Map.put(:store, new_store)
  end

  defcast dispatch(action = :touch), state: state = %{store: store} do
    new_store = store |> Store.dispatch({:backlight, :on}) |> Store.dispatch(action)
    new_state state |> schedule_idle_timeout |> Map.put(:store, new_store)
  end

  defcast dispatch(action), state: state = %{store: store} do
    new_store = Store.dispatch store, action
    new_state state |> Map.put(:store, new_store)
  end

  defhandleinfo :clock_tick, state: state = %{store: store} do
    new_store = Store.dispatch store, :clock_tick
    new_state state |> schedule_clock_tick |> Map.put(:store, new_store)
  end

  defhandleinfo :alarm_check, state: state = %{store: store} do
    new_store = Store.dispatch store, :alarm_check
    new_state state |> schedule_alarm_check |> Map.put(:store, new_store)
  end

  def handle_info :idle_timeout, state = %{store: store} do
    new_store = Store.dispatch store, {:backlight, :off}
    new_state state |> Map.put(:store, new_store) |> Map.put(:idle_timer, nil)
  end

  defp create_store do
    Store.new %{
      alarm_active: Settings.get(:alarm_active),
      alarm_hour: Settings.get(:alarm_hour),
      alarm_minute: Settings.get(:alarm_minute),
      sunrise_duration: Settings.get(:sunrise_duration),
      max_brightness: Settings.get(:max_brightness),
      time_zone: Settings.get(:time_zone),
      page: :boot,
      alarm: :boot,
      time: Timex.now(Settings.get :time_zone),
      brightness: 0,
      brightness_delta: 0,
      backlight: :off
    }
  end

  defp add_store_reducers store do
    store
    |> Store.reduce(LogicUiReducers)
    |> Store.reduce(LogicAlarmReducers)
    |> Store.reduce(LogicSettingsReducers)
  end

  defp add_store_subscribers store do
    store
    |> Store.subscribe(&LogicUiSubscribers.update/2)
    |> Store.subscribe(&LogicUiSubscribers.leave_page/2)
    |> Store.subscribe(&LogicUiSubscribers.update_page/2)
    |> Store.subscribe(LogicAlarmSubscribers)
    |> Store.subscribe(LogicSettingsSubscribers)
  end

  defp create_state store do
    %{
      store: store,
      idle_timer: nil
    }
  end

  defp init_schedules state do
    state
    |> schedule_clock_tick
    |> schedule_alarm_check
    |> schedule_idle_timeout
  end

  defp schedule_clock_tick state do
    Process.send_after self(), :clock_tick, @clock_interval
    state
  end

  defp schedule_alarm_check state do
    Process.send_after self(), :alarm_check, @alarm_check_interval
    state
  end

  defp schedule_idle_timeout state = %{idle_timer: timer} do
    if timer, do: Process.cancel_timer timer
    timer = Process.send_after self(), :idle_timeout, @idle_timout
    %{state | idle_timer: timer}
  end
end
