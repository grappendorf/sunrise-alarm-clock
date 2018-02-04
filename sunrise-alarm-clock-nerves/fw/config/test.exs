use Mix.Config

config :fw, :misc,
  env: :test

config :logger,
  level: :warn

config :ui, UiWeb.Endpoint,
  http: [port: 4001],
  server: false
