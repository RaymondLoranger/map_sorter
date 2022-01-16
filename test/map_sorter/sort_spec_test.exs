defmodule MapSorter.SortSpecTest do
  use ExUnit.Case, async: false

  alias MapSorter.SortSpec

  doctest SortSpec, only: TestHelper.doctests(SortSpec)
end
