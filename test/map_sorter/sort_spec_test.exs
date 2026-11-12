defmodule MapSorter.SortSpecTest do
  use ExUnit.Case, async: true

  alias MapSorter.SortSpec

  doctest SortSpec, only: TestHelper.doctests(SortSpec)
end
