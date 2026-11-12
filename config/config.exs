import Config

# import_config "config_logger.exs"
import_config "config_test_selection.exs"

# For testing purposes only...
config :map_sorter,
  env: "#{Mix.env()} ➔ from #{Path.relative_to_cwd(__ENV__.file)}"

# Proposal of a Comparable protocol...
config :map_sorter,
  comparable_protocol:
    "[comparable protocol]" <>
      "(https://groups.google.com/forum/#!topic/elixir-lang-core/eE_mMWKdVYY)"

# Compare function for Enum.sort/2...
config :map_sorter,
  compare_function:
    "[compare function](https://hexdocs.pm/elixir/Enum.html#sort/2)"
