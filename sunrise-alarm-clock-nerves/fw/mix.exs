defmodule Fw.MixProject do
  use Mix.Project

  @target System.get_env("MIX_TARGET") || "host"

  Mix.shell().info([
    :green,
    """
    Mix environment
      MIX_TARGET:   #{@target}
      MIX_ENV:      #{Mix.env()}
    """,
    :reset
  ])

  def project do
    [
      app: :fw,
      version: "0.1.0",
      elixir: "~> 1.6",
      target: @target,
      archives: [nerves_bootstrap: "~> 0.7"],
      deps_path: "deps/#{@target}",
      build_path: "_build/#{@target}",
      lockfile: "mix.lock.#{@target}",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      aliases: aliases(@target),
      deps: deps(),
      preferred_cli_env: [espec: :test, specs: :test]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application, do: application(@target)

  # Specify target specific application configurations
  # It is common that the application start function will start and supervise
  # applications which could cause the host to fail. Because of this, we only
  # invoke Fw.start/2 when running on a target.
  def application("host") do
    [mod: {Fw.Application, []}, applications: [:logger, :timex, :ui]]
  end

  def application(_target) do
    [mod: {Fw.Application, []}, extra_applications: [:logger]]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [{:nerves, "~> 0.9", runtime: false}] ++ deps(@target)
  end

  # Specify target specific dependencies
  #  defp deps("host"), do: []

  defp deps(target) do
    [
      {:shoehorn, "~> 0.2"},
      {:nerves_runtime, "~> 0.4"},
      {:nerves_network, "~> 0.3"},
      {:nerves_firmware_http, "~> 0.4"},
      {:elixir_ale, "~> 1.0"},
      {:exactor, "~> 2.2"},
      {:timex, "~> 3.1"},
      {:exprintf, "~> 0.2"},
      {:poison, "~> 3.1"},
      {:persistent_storage, git: "https://github.com/grappendorf/persistent_storage.git", branch: "master"},
      {:fsm, git: "https://github.com/grappendorf/fsm.git", branch: "master"},
      {:espec, "~> 1.5", only: :test},
      {:ui, path: "../ui"}
    ] ++ system(target)
  end

  defp system("rpi"), do: [{:nerves_system_rpi, ">= 0.0.0", runtime: false}]
  defp system("rpi0"), do: [{:nerves_system_rpi0, ">= 0.0.0", runtime: false}]
  defp system("rpi2"), do: [{:nerves_system_rpi2, ">= 0.0.0", runtime: false}]
  defp system("rpi3"), do: [{:nerves_system_rpi3, ">= 0.0.0", runtime: false}]
  defp system("bbb"), do: [{:nerves_system_bbb, ">= 0.0.0", runtime: false}]
  defp system("ev3"), do: [{:nerves_system_ev3, ">= 0.0.0", runtime: false}]
  defp system("qemu_arm"), do: [{:nerves_system_qemu_arm, ">= 0.0.0", runtime: false}]
  defp system("x86_64"), do: [{:nerves_system_x86_64, ">= 0.0.0", runtime: false}]
  defp system("host"), do: [{:nerves_system_rpi, ">= 0.0.0", runtime: false}]
  defp system(target), do: Mix.raise "Unknown MIX_TARGET: #{target}"

  # We do not invoke the Nerves Env when running on the Host
  defp aliases("host") do
    [
      "specs": ["espec"]
    ]
  end

  defp aliases(_target) do
    []
    |> Nerves.Bootstrap.add_aliases()
  end
end
