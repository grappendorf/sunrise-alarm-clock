use Mix.Config

config :fw, :misc,
  env: :dev

config :logger,
  level: :info

config :ui, Ui.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [],
  live_reload: [
    patterns: [
      ~r{ui/priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{ui/priv/gettext/.*(po)$},
      ~r{ui/web/views/.*(ex)$},
      ~r{ui/web/templates/.*(eex)$}]]
