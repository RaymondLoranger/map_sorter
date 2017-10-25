# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :elixir, ansi_enabled: true # mix messages in colors

# Comment out the following line to compile debug messages...
config :logger, compile_time_purge_level: :info # :info purges debug messages
config :logger, level: :info # :info prevents runtime debug messages
config :logger, :console, colors: [
  # by ascending log level:
  debug: :light_cyan,
  info: :light_green,
  warn: :light_yellow,
  error: :light_red
]
