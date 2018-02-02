# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# To allow mix messages in colors...
config :elixir, ansi_enabled: true

# When false (or nil), will simplify the compare function AST...
# config :map_sorter, sorting_on_structs?: true

# Should both be overridden by "persist.exs"...
config :logger, compile_time_purge_level: :debug
config :logger, level: :debug

import_config "persist.exs"
