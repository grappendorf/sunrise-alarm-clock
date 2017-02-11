defmodule Fw do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = case Application.get_env(:fw, :misc)[:env] do
      :prod -> [
        worker(Lcd, []),
        worker(Leds, []),
        worker(Nerves.InterimWiFi, [:wlan0, Application.get_env(:fw, :wlan)], function: :setup),
        worker(Nerves.Networking, [:wlan0], function: :setup),
        worker(Nerves.Ntp.Worker, []),
        worker(Buttons, [&Logic.dispatch/1]),
        worker(Touch, [&Logic.dispatch/1]),
        worker(Settings, []),
        worker(Logic, [])]
      :dev -> [
        worker(Sim.Lcd, []),
        worker(Sim.Leds, []),
        worker(Sim.Buttons, [&Logic.dispatch/1]),
        worker(Sim.Touch, [&Logic.dispatch/1]),
        worker(Sim.Settings, []),
        worker(Logic, [])]
      :test -> []
    end

    {:ok, _} = Supervisor.start_link children, strategy: :one_for_one, name: Fw.Supervisor
  end
end
