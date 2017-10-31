# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# To allow mix messages in colors...
config :elixir, ansi_enabled: true

# Comment out the following line to compile debug messages...
# config :logger, compile_time_purge_level: :info # ⟹ purges debug messages

config :logger, level: :info # ⟹ prevents runtime debug messages

# Listed by ascending log level...
config :logger, :console, colors: [
  debug: :light_cyan,
  info: :light_green,
  warn: :light_yellow,
  error: :light_red
]
