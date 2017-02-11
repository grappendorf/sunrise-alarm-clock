use Mix.Config

config :fw, :misc,
  env: :test

config :logger,
  level: :warn

config :ui, Ui.Endpoint,
  http: [port: 4001],
  server: false
