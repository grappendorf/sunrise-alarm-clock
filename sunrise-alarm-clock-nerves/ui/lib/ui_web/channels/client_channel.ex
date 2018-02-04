defmodule UiWeb.ClientChannel do
  use Phoenix.Channel
  require Logger

  def join "client", _, socket do
    {:ok, socket}
  end

  def publish_store_changed state, old do
    UiWeb.Endpoint.broadcast("client", "store_changed", %{
      state: state,
      old_state: old})
    if Fw.Application.target == "host" do
      UiWeb.Endpoint.broadcast("client", "sim_changed", %{
        lcd: Fw.Sim.Lcd.state(),
        leds: Fw.Sim.Leds.state()})
    end
  end

  def handle_in "button_pressed", %{"num" => num}, socket do
    Fw.Sim.Buttons.press num
    {:noreply, socket}
  end

  def handle_in "touched", _, socket do
    Fw.Sim.Touch.touch
    {:noreply, socket}
  end
end
