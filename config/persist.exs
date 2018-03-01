use Mix.Config

# Comment out to compile debug, info and warn messages...
config :map_sorter, purge_level: :error

# Proposal of a Comparable protocol...
config :map_sorter,
  comparable_protocol_url:
    "https://groups.google.com/forum/#!topic/elixir-lang-core/eE_mMWKdVYY"

# Compare function for Enum.sort/2...
config :map_sorter,
  compare_function_url: "https://hexdocs.pm/elixir/Enum.html#sort/2"
