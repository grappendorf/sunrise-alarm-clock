use Mix.Config

config :fw, :misc,
  env: :dev

config :logger,
  level: :debug

config :ui, UiWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true
