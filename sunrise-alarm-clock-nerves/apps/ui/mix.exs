defmodule Ui.Mixfile do
  use Mix.Project

  @target System.get_env("NERVES_TARGET") || "rpi"

  def project do
    [app: :ui,
     version: "0.0.1",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps/#{@target}",
     lockfile: "../../mix.lock",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [mod: {Ui, []},
     applications: [:phoenix, :phoenix_pubsub, :phoenix_html, :phoenix_ecto, :cowboy, :logger, :gettext]]
  end

  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  defp deps do
    [{:phoenix, "~> 1.2.0"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:phoenix_ecto, "3.0.1"},
     {:gettext, "~> 0.11"},
     {:cowboy, "~> 1.0"}]
  end
end
