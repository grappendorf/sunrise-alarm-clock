defmodule Fw.Mixfile do
  use Mix.Project

  @target System.get_env("NERVES_TARGET") || "rpi"

  def project do
    [
      app: :fw,
      version: "0.0.1",
      target: @target,
      archives: [nerves_bootstrap: "~> 0.2.1"],
      deps_path: "../../deps/#{@target}",
      build_path: "../../_build/#{@target}",
      lock_file: "../../mix.lock",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps() ++ system(@target),
      preferred_cli_env: [espec: :test, specs: :test]
    ]
  end

  def application do
    applications = case Application.get_env(:fw, :misc)[:start_children] do
      true -> [
        :logger,
        :elixir_ale,
        :nerves_interim_wifi,
        :nerves_networking,
        :nerves_firmware_http,
        :nerves_ntp,
        :exprintf,
        :timex,
        :persistent_storage,
        :fsm,
        :ui
      ]
      false -> [
        :logger,
        :timex
      ]
     end
    [
      mod: {Fw, []},
      applications: applications
    ]
  end

  def deps do
    [
      {:nerves, "~> 0.4.7"},
      {:elixir_ale, "~> 0.5.6"},
      {:nerves_networking, "~> 0.6.0"},
      {:nerves_interim_wifi, "~> 0.1.1"},
      {:nerves_firmware_http, github: "nerves-project/nerves_firmware_http"},
      {:nerves_ntp, "~> 0.1.1"},
      {:exactor, "~> 2.2.3"},
      {:exprintf, "~> 0.2.0"},
      {:timex, "~> 3.1.8"},
      {:fsm, git: "https://github.com/grappendorf/fsm.git", branch: "master"},
      {:persistent_storage, git: "https://github.com/grappendorf/persistent_storage.git", branch: "master"},
      {:espec, "1.2.2", only: :test},
      {:ui, in_umbrella: true}
    ]
  end

  def system(target) do
    [
      {:"nerves_system_#{target}", ">= 0.0.0"}
    ]
  end

  def aliases do
    [
      "deps.precompile": ["nerves.precompile", "deps.precompile"],
      "deps.loadpaths":  ["deps.loadpaths", "nerves.loadpaths"],
      "specs": ["espec"]
    ]
  end
end

defmodule Mix.Tasks.Firmware.Ota do
  use Mix.Task

  @shortdoc "Upload a firmware"

  def run(_) do
    IO.puts "Uploading the firmware..."
    System.cmd "bash", ["../../bin/upload_firmware.sh"]
  end
end
