defmodule Ui.ClientChannel do
  use Phoenix.Channel
  require Logger

  def join "client", _, socket do
    {:ok, socket}
  end

  def publish_store_changed state, old do
    Ui.Endpoint.broadcast("client", "store_changed", %{
      state: state,
      old_state: old})
    if Application.get_env(:fw, :misc)[:env] == :dev do
      Ui.Endpoint.broadcast("client", "sim_changed", %{
        lcd: Sim.Lcd.state(),
        leds: Sim.Leds.state()})
    end
  end

  def handle_in "button_pressed", %{"num" => num}, socket do
    Sim.Buttons.press num
    {:noreply, socket}
  end

  def handle_in "touched", _, socket do
    Sim.Touch.touch
    {:noreply, socket}
  end
end
