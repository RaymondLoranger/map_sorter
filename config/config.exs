# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# To allow mix messages in colors...
config :elixir, ansi_enabled: true

# When false (or nil), will simplify the compare function AST...
# config :map_sorter, sorting_on_structs?: true

import_config "persist.exs"
