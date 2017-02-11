defmodule Ui.SimController do
  use Ui.Web, :controller

  def index conn, _params do
    render conn, "index.html",
      lcd: Sim.Lcd.state(),
      leds: Sim.Leds.state(),
      logic: Logic.state()
  end

  def buttons conn, params do
    Sim.Buttons.press String.to_integer(params["num"])
    send_resp conn, 201, ""
  end
end
