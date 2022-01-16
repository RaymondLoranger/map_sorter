import Config

# Proposal of a Comparable protocol...
config :map_sorter,
  comparable_protocol:
    "[comparable protocol]" <>
      "(https://groups.google.com/forum/#!topic/elixir-lang-core/eE_mMWKdVYY)"

# Compare function for Enum.sort/2...
config :map_sorter,
  compare_function:
    "[compare function](https://hexdocs.pm/elixir/Enum.html#sort/2)"
