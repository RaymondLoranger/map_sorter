import Config

# Allows to run the doctest(s) of one function at a time...
config :map_sorter,
  doctests: %{
    MapSorter.Compare => [
      # fun: 1,
      # heredoc: 1,
    ],
    MapSorter.Cond => [
      # clauses: 1,
    ],
    MapSorter.SortSpec => [
      # brackets: 1,
    ],
    MapSorter.SortSpecs => [
      # to_quoted: 1,
    ],
    MapSorter => [
      # sort: 2,
    ],
  }

# Allows to run one test at a time...
config :map_sorter,
  excluded_tags: [
    # :compare_test_1,
    :compare_test_2,

    :sort_specs_test_1,
    :sort_specs_test_2,
    :sort_specs_test_3,
    :sort_specs_test_4,

    :map_sorter_test_1,
    :map_sorter_test_2,
    :map_sorter_test_3,
    :map_sorter_test_4,
    :map_sorter_test_5,
    :map_sorter_test_6,
    :map_sorter_test_7,
    :map_sorter_test_8,
    :map_sorter_test_9,
    :map_sorter_test_10,
    :map_sorter_test_11,
    :map_sorter_test_12,
    :map_sorter_test_13,
    :map_sorter_test_14,
    :map_sorter_test_15,
    :map_sorter_test_16,
    :map_sorter_test_17,
    :map_sorter_test_18,
    :map_sorter_test_19,
    :map_sorter_test_20,
    :map_sorter_test_21,
    :map_sorter_test_22,
    :map_sorter_test_23,
    :map_sorter_test_24,
    :map_sorter_test_25,
  ]
