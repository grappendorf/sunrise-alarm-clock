defmodule Fw do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Lcd, []),
      worker(Leds, []),
      worker(Nerves.InterimWiFi, [:wlan0, Application.get_env(:fw, :wlan)], function: :setup),
      worker(Nerves.Networking, [:wlan0], function: :setup),
      worker(Nerves.Ntp.Worker, []),
      worker(Buttons, []),
      worker(Touch, []),
      worker(Settings, []),
      worker(LogicAlarm, []),
      worker(LogicUi, [])
    ]

    {:ok, _} = Supervisor.start_link children,
      strategy: :one_for_one, name: Fw.Supervisor
  end
end
