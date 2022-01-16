defmodule MapSorter.CompareTest do
  use ExUnit.Case, async: false

  alias MapSorter.Compare

  doctest Compare, only: TestHelper.doctests(Compare)

  setup_all do: SetupTest.setup_all(__MODULE__)

  describe "Compare.fun/1" do
    @tag :compare_test_1
    TestHelper.config_level(__MODULE__)

    test "returns a sort function", context do
      comp_fun = Compare.fun([:dob, desc: :likes])
      assert comp_fun == context.here_fun
      assert is_function(comp_fun, 2)
      assert comp_fun.(%{likes: "ski"}, %{likes: "art"})
      refute comp_fun.(%{likes: "art"}, %{likes: "ski"})
    end

    Logger.configure(level: :all)

    @tag :compare_test_2
    TestHelper.config_level(__MODULE__)

    test ~S[returns a "true" function given bad specs], context do
      tuple_comp_fun = Compare.fun({:dob, :desc, :likes})
      empty_comp_fun = Compare.fun([])
      nihil_comp_fun = Compare.fun(nil)
      assert tuple_comp_fun == context.true_fun
      assert empty_comp_fun == context.true_fun
      assert nihil_comp_fun == context.true_fun
      assert is_function(tuple_comp_fun, 2)
      assert is_function(empty_comp_fun, 2)
      assert is_function(nihil_comp_fun, 2)
      assert tuple_comp_fun.(%{any: 0}, %{any: 9})
      assert tuple_comp_fun.(%{any: 9}, %{any: 0})
      assert empty_comp_fun.(%{any: 0}, %{any: 9})
      assert empty_comp_fun.(%{any: 9}, %{any: 0})
      assert nihil_comp_fun.(%{any: 0}, %{any: 9})
      assert nihil_comp_fun.(%{any: 9}, %{any: 0})
    end

    Logger.configure(level: :all)
  end
end
