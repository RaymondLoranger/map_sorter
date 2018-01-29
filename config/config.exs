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
config :logger, :console,
  colors: [
    debug: :light_cyan,
    info: :light_green,
    warn: :light_yellow,
    error: :light_red
  ]

# When false (or nil), will simplify the compare function AST...
# config :map_sorter, sorting_on_structs?: true

import_config "persist.exs"
