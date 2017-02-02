defmodule Settings do
  use GenServer

  @default_values %{
    alarm_active: false,
    alarm_hour: 0,
    alarm_minute: 0,
    dimmer_advance: 15,
    max_brightness: 0,
    time_zone: 1,
  }

  def start_link do
    GenServer.start_link __MODULE__, nil, name: :settings
  end

  def init _ do
    :ok = PersistentStorage.setup path: "/root/settings"
    {:ok, %{}}
  end

  def put key, value do
    GenServer.cast :settings, {:put, key, value}
  end

  def get key do
    GenServer.call :settings, {:get, key}
  end

  def handle_cast {:put, key, value}, state do
    PersistentStorage.put key, value
    {:noreply, state}
  end

  def handle_call {:get, key}, _, state do
    {:reply, PersistentStorage.get(key, @default_values[key]), state}
  end
end
