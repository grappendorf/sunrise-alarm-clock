use Mix.Config

config :fw, :misc,
  env: :prod

config :logger,
  level: :debug

config :ui, Ui.Endpoint,
  secret_key_base: "<YOUR SECRET KEY BASE IN LOCAL.EXS>"
