defmodule Fw.Buttons do
  use ExActor.GenServer, export: :buttons
  alias ElixirALE.GPIO

  @button_1_pin Application.get_env(:fw, :buttons)[:button_1_pin]
  @button_2_pin Application.get_env(:fw, :buttons)[:button_2_pin]
  @button_3_pin Application.get_env(:fw, :buttons)[:button_3_pin]
  @button_4_pin Application.get_env(:fw, :buttons)[:button_4_pin]
  @button_debounce_interval_ms Application.get_env(:fw, :buttons)[:button_debounce_interval]

  defstart start_link action_dispatch do
    {:ok, button_1} = GPIO.start_link @button_1_pin, :input
    {:ok, button_2} = GPIO.start_link @button_2_pin, :input
    {:ok, button_3} = GPIO.start_link @button_3_pin, :input
    {:ok, button_4} = GPIO.start_link @button_4_pin, :input
    GPIO.set_int button_1, :falling
    GPIO.set_int button_2, :falling
    GPIO.set_int button_3, :falling
    GPIO.set_int button_4, :falling
    initial_state %{
      action_dispatch: action_dispatch,
      button_1: button_1,
      button_2: button_2,
      button_3: button_3,
      button_4: button_4}
  end

  defhandleinfo {:gpio_interrupt, @button_1_pin, :falling},
      state: %{action_dispatch: action_dispatch, button_1: button} do
    debounce_then_call button, fn -> action_dispatch.({:button, 1}) end
    noreply()
  end

  defhandleinfo {:gpio_interrupt, @button_2_pin, :falling},
      state: %{action_dispatch: action_dispatch, button_2: button} do
    debounce_then_call button, fn -> action_dispatch.({:button, 2}) end
    noreply()
  end

  defhandleinfo {:gpio_interrupt, @button_3_pin, :falling},
      state: %{action_dispatch: action_dispatch, button_3: button} do
    debounce_then_call button, fn -> action_dispatch.({:button, 3}) end
    noreply()
  end

  defhandleinfo {:gpio_interrupt, @button_4_pin, :falling},
      state: %{action_dispatch: action_dispatch, button_4: button} do
    debounce_then_call button, fn -> action_dispatch.({:button, 4}) end
    noreply()
  end

  defhandleinfo {:gpio_interrupt, _, _} do
    noreply()
  end

  defp debounce_then_call button, func do
    receive do
      _ -> nil
    after
      @button_debounce_interval_ms -> if GPIO.read(button) == 0, do: func.()
    end
  end
end
