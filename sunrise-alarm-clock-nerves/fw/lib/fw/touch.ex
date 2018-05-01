defmodule Fw.Touch do
  use ExActor.GenServer, export: :touch
  use Bitwise
  alias ElixirALE.GPIO

  @interrupt_pin Application.get_env(:fw, :touch)[:interrupt_pin]

  defstart start_link action_dispatch do
    {:ok, interrupt} = GPIO.start_link @interrupt_pin, :input
    GPIO.set_int interrupt, :rising
    initial_state %{
      action_dispatch: action_dispatch,
      interrupt: interrupt}
  end

  defhandleinfo {:gpio_interrupt, @interrupt_pin, :rising},
      state: %{action_dispatch: action_dispatch} do
    action_dispatch.(:touch)
    noreply()
  end

  defhandleinfo {:gpio_interrupt, _, _} do
    noreply()
  end
end
