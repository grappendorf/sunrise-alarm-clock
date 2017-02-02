use Mix.Config

config :ui, Ui.Endpoint,
  http: [port: 4001],
  server: false

config :logger, level: :warn
