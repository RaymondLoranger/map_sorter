defmodule MapSorter.CompareTest do
  use ExUnit.Case, async: true
  use PersistConfig

  alias MapSorter.Compare

  @included_tags get_env(:included_tags)

  doctest Compare, only: TestHelper.doctests(Compare)

  setup_all do: TestHelper.Context.setup_all(__MODULE__)

  describe "Compare.fun/1" do
    if :compare_test_1 in @included_tags do
      test "returns a compare function", context do
        comp_fun = Compare.fun(asc: :dob, desc: :likes)
        assert comp_fun == context.here_fun
        assert is_function(comp_fun, 2)
        assert comp_fun.(%{likes: "ski"}, %{likes: "art"})
        refute comp_fun.(%{likes: "art"}, %{likes: "ski"})
      end
    end

    if :compare_test_2 in @included_tags do
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
        assert empty_comp_fun.(:any, ANY)
        assert empty_comp_fun.(:pi, 3.1416)
        assert nihil_comp_fun.(0, :infinity)
        assert nihil_comp_fun.({}, %{})
      end
    end
  end
end
