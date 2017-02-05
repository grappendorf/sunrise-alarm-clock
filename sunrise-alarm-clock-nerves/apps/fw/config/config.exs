use Mix.Config

config :nerves, :firmware,
  rootfs_additions: "rootfs-additions"

config :nerves_interim_wifi,
  regulatory_domain: "DE"

config :fw, :wlan,
  key_mgmt: :"WPA-PSK",
  ssid: "<SET YOUR SSID IN LOCAL.EXS",
  psk: "<SET YOUR PASSPHRASE IN LOCAL.EXS>"

config :nerves_ntp, :ntpd, "/usr/sbin/ntpd"

config :nerves_ntp, :servers, [
  "0.pool.ntp.org",
  "1.pool.ntp.org",
  "2.pool.ntp.org",
  "3.pool.ntp.org"
]

config :fw, :misc,
  display_timeout: 30,
  start_children: true,
  version: "0.2.0"

config :fw, :buttons,
  button_1_pin: 12,
  button_2_pin: 16,
  button_3_pin: 20,
  button_4_pin: 21,
  button_debounce_interval: 200

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

config :ui, Ui.Endpoint,
  http: [port: 80],
  url: [host: "localhost", port: 80],
  secret_key_base: "9w9MI64d1L8mjw+tzTmS3qgJTJqYNGJ1dNfn4S/Zm6BbKAmo2vAyVW7CgfI3CpII",
  root: Path.dirname(__DIR__),
  server: true,
  render_errors: [accepts: ~w(html json)],
  pubsub: [
    name: Ui.PubSub,
    adapter: Phoenix.PubSub.PG2]

import_config "#{Mix.env}.exs"
import_config "local.exs"
