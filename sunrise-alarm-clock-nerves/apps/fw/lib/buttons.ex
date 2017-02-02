defmodule Buttons do
  use GenServer

  @button_1_pin Application.get_env(:fw, :buttons)[:button_1_pin]
  @button_2_pin Application.get_env(:fw, :buttons)[:button_2_pin]
  @button_3_pin Application.get_env(:fw, :buttons)[:button_3_pin]
  @button_4_pin Application.get_env(:fw, :buttons)[:button_4_pin]
  @button_debounce_interval_ms Application.get_env(:fw, :buttons)[:button_debounce_interval]

  def start_link do
    GenServer.start_link __MODULE__, nil, name: :buttons
  end

  def init _ do
    {:ok, button_1} = Gpio.start_link @button_1_pin, :input
    {:ok, button_2} = Gpio.start_link @button_2_pin, :input
    {:ok, button_3} = Gpio.start_link @button_3_pin, :input
    {:ok, button_4} = Gpio.start_link @button_4_pin, :input
    Gpio.set_int button_1, :falling
    Gpio.set_int button_2, :falling
    Gpio.set_int button_3, :falling
    Gpio.set_int button_4, :falling
    {:ok, %{
      button_1: button_1,
      button_2: button_2,
      button_3: button_3,
      button_4: button_4,
      last_button_press_time: 0
    }}
  end

  def handle_info {:gpio_interrupt, @button_1_pin, :falling}, state do
    _debounce_then_call fn -> LogicUi.button_pressed 1 end
    {:noreply, state}
  end

  def handle_info {:gpio_interrupt, @button_2_pin, :falling}, state do
    _debounce_then_call fn -> LogicUi.button_pressed 2 end
    {:noreply, state}
  end

  def handle_info {:gpio_interrupt, @button_3_pin, :falling}, state do
    _debounce_then_call fn -> LogicUi.button_pressed 3 end
    {:noreply, state}
  end

  def handle_info {:gpio_interrupt, @button_4_pin, :falling}, state do
    _debounce_then_call fn -> LogicUi.button_pressed 4 end
    {:noreply, state}
  end

  def handle_info {:gpio_interrupt, _, _}, state do
    {:noreply, state}
  end

  defp _debounce_then_call func do
    receive do
      _ -> nil
    after
      @button_debounce_interval_ms -> nil
    end
    func.()
  end
end
