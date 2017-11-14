# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# To allow mix messages in colors...
config :elixir, ansi_enabled: true

# Comment out to compile debug, info and warn messages...
config :logger, compile_time_purge_level: :error

# Prevents runtime debug, info and warn messages...
config :logger, level: :error

# Listed by ascending log level...
config :logger, :console, colors: [
  debug: :light_cyan,
  info:  :light_green,
  warn:  :light_yellow,
  error: :light_red
]

# Proposal of a Comparable protocol...
config :map_sorter, comparable_protocol_url:
  "https://groups.google.com/forum/#!topic/elixir-lang-core/eE_mMWKdVYY"

# Compare function for Enum.sort/2...
config :map_sorter, compare_function_url:
  "https://hexdocs.pm/elixir/Enum.html#sort/2"

# When false, will simplify the compare function AST...
config :map_sorter, structs_enabled?: false
