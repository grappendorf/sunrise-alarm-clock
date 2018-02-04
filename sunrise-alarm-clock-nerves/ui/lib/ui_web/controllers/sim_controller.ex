defmodule UiWeb.SimController do
  use UiWeb, :controller

  def index conn, _params do
    render conn, "index.html",
      lcd: Fw.Sim.Lcd.state(),
      leds: Fw.Sim.Leds.state(),
      logic: Fw.Logic.state()
  end

  def buttons conn, params do
    Fw.Sim.Buttons.press String.to_integer(params["num"])
    send_resp conn, 201, ""
  end
end
