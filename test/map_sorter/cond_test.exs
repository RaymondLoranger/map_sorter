defmodule MapSorter.CondTest do
  use ExUnit.Case, async: false

  alias MapSorter.Cond

  doctest Cond, only: TestHelper.doctest(Cond)
end
