defmodule MapSorter.ContainerTest do
  use ExUnit.Case, async: false

  alias MapSorter.Container

  doctest Container, only: TestHelper.doctest(Container)
end
