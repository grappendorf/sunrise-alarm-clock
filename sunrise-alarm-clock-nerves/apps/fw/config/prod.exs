use Mix.Config

config :logger, level: :debug

config :ui, Ui.Endpoint,
  secret_key_base: "<YOUR SECRET KEY BASE IN LOCAL.EXS>"
