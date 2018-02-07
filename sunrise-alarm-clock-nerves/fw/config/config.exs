use Mix.Config

config :shoehorn,
  init: [:nerves_runtime],
  app: Mix.Project.config()[:app]

config :ui, UiWeb.Endpoint,
  url: [host: "localhost"],
  http: [port: 80],
  secret_key_base: "50e0xWXTVedNsgcyBF94vg2BlEOgMLv2upl1Qtu7eO0s7DpT0TlqXUXqhpnAYtpC",
  root: Path.dirname(__DIR__),
  server: true,
  render_errors: [view: UiWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Nerves.PubSub, adapter: Phoenix.PubSub.PG2],
  code_reloader: false,
  check_origin: false

config :logger, level: :debug

config :bootloader,
  init: [:nerves_runtime, :nerves_network]

config :nerves, :firmware,
  rootfs_overlay: "rootfs_overlay"

config :nerves_network,
  regulatory_domain: "DE"

config :nerves_network, :default,
  eth0: [
    ipv4_address_method: :dhcp
  ]

config :nerves_firmware_http,
  json_provider: Poison,
  timeout: 240 * 1000

config :fw, :ntpd,
  startup_delay: 60 * 1000,
  restart_delay: 60 * 1000,
  command: "/usr/sbin/ntpd",
  servers: [
    "0.pool.ntp.org",
    "1.pool.ntp.org",
    "2.pool.ntp.org",
    "3.pool.ntp.org"]

config :fw, :misc,
  display_timeout: 30,
  start_children: true,
  persistent_storage_dir: "/root/settings",
  version: "0.3.1"

config :fw, :buttons,
  button_1_pin: 12,
  button_2_pin: 16,
  button_3_pin: 20,
  button_4_pin: 21,
  button_debounce_interval: 10

config :fw, :touch,
  interrupt_pin: 26

config :fw, :lcd,
  i2c_address: 0x20,
  lines: 2,
  chars: 16,
  line_length: 64,
  line_1_start: 0x00,
  line_2_start: 0x40,
  wrap: 0

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations
#
# import_config "#{Mix.Project.config[:target]}.exs"

import_config "#{Mix.env}.exs"
import_config "local.exs"
