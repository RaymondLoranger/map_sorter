defmodule MapSorter.SortSpecsTest do
  use ExUnit.Case, async: false

  alias MapSorter.{Compare, SortSpecs, TestSetup}

  doctest SortSpecs, only: TestHelper.doctests(SortSpecs)

  setup_all do: TestSetup.setup_all(__MODULE__)

  describe "SortSpecs.to_quoted/1" do
    @tag :sort_specs_test_1
    TestHelper.config_level(__MODULE__)

    test "works for compile time sort specs", context do
      {:ok, comp_fun_ast} = SortSpecs.to_quoted(context.sort_specs)
      {comp_fun, []} = Code.eval_quoted(comp_fun_ast)
      assert comp_fun_ast == context.here_ast
      assert match?({:&, _meta, _args}, comp_fun_ast)
      assert match?([_, _], context.sort_specs)
      assert comp_fun == context.here_fun
      assert is_function(comp_fun, 2)
    end

    Logger.configure(level: :all)

    @tag :sort_specs_test_2
    TestHelper.config_level(__MODULE__)

    test "works for runtime sort specs", context do
      {:ok, comp_fun_ast} = SortSpecs.to_quoted(context.tuple_ast)
      assert Macro.to_string(comp_fun_ast) == context.tuple_str
      fun = Compare.fun(context.sort_specs)
      {comp_fun, []} = Code.eval_quoted(comp_fun_ast)
      assert Tuple.to_list(context.tuple) == context.sort_specs
      assert comp_fun == fun
      assert is_function(comp_fun, 2)
      assert match?({{:., _, _}, _meta, _args}, comp_fun_ast)
      assert match?({{:., _, _}, _meta, _args}, context.tuple_ast)
    end

    Logger.configure(level: :all)

    @tag :sort_specs_test_3
    TestHelper.config_level(__MODULE__)

    test "works for empty sort specs" do
      sort_specs = []
      {:ok, comp_fun_ast} = SortSpecs.to_quoted(sort_specs)
      assert match?({:&, _meta, _args}, comp_fun_ast)
      assert match?([], sort_specs)
    end

    Logger.configure(level: :all)

    @tag :sort_specs_test_4
    TestHelper.config_level(__MODULE__)

    test "detects bad specs" do
      nil_sort_specs = nil
      map_sort_specs = %{asc: :dob, desc: :likes}
      tuple_sort_specs = {:height, desc: :weight}
      pid_sort_specs = self()
      {:error, nil_bad_specs} = SortSpecs.to_quoted(nil_sort_specs)
      {:error, map_bad_specs} = SortSpecs.to_quoted(map_sort_specs)
      {:error, tuple_bad_specs} = SortSpecs.to_quoted(tuple_sort_specs)
      {:error, pid_bad_specs} = SortSpecs.to_quoted(pid_sort_specs)
      assert nil_bad_specs == nil_sort_specs
      assert map_bad_specs == map_sort_specs
      assert tuple_bad_specs == tuple_sort_specs
      assert pid_bad_specs == pid_sort_specs
    end

    Logger.configure(level: :all)
  end
end
