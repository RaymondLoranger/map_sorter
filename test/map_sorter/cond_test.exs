defmodule MapSorter.CondTest do
  use ExUnit.Case, async: true

  alias MapSorter.Cond

  doctest Cond, only: TestHelper.doctests(Cond)
end
