defmodule Fw.Application do
  use Application
  alias Fw.{Buttons, Lcd, Leds, Logic, Settings, Sim, Touch}

  @target Mix.Project.config[:target]

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = case {target(), env()} do
      {"host", :dev} -> [
        worker(Sim.Lcd, []),
        worker(Sim.Leds, []),
        worker(Sim.Buttons, [&Logic.dispatch/1]),
        worker(Sim.Touch, [&Logic.dispatch/1]),
        worker(Sim.Settings, []),
        worker(Logic, [])]
      {"host", :test} -> []
      {_, _} -> [
        worker(Ntpd, []),
        worker(Lcd, []),
        worker(Leds, []),
        worker(Buttons, [&Logic.dispatch/1]),
        worker(Touch, [&Logic.dispatch/1]),
        worker(Settings, []),
        worker(Logic, [])]
    end

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Fw.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def target do
    @target
  end

  def env do
    Application.get_env(:fw, :misc)[:env]
  end
end
