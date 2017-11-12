# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# To allow mix messages in colors...
config :elixir, ansi_enabled: true

# Comment out to compile debug messages...
config :logger, compile_time_purge_level: :info

# Prevents runtime debug messages...
config :logger, level: :info

# Listed by ascending log level...
config :logger, :console, colors: [
  debug: :light_cyan,
  info:  :light_green,
  warn:  :light_yellow,
  error: :light_red
]

config :map_sorter, comparable_protocol_url:
  "https://groups.google.com/forum/#!topic/elixir-lang-core/eE_mMWKdVYY"

# When false, will simplify the sort function AST...
config :map_sorter, structs_enabled?: false
