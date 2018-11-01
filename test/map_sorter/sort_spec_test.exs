defmodule MapSorter.SortSpecTest do
  use ExUnit.Case, async: false
  use PersistConfig

  alias MapSorter.SortSpec

  @sorting_on_structs? Application.get_env(@app, :sorting_on_structs?, false)

  doctest SortSpec

  setup_all do
    true_doc = """
    & cond do
    true -> true or &1 * &2
    end
    """

    {:ok, true_ast} = true_doc |> Code.string_to_quoted()
    {true_fun, []} = true_doc |> Code.eval_string()

    here_doc = """
    & cond do
    &1[:dob] < &2[:dob] -> true
    &1[:dob] > &2[:dob] -> false
    &1[:likes] > &2[:likes] -> true
    &1[:likes] < &2[:likes] -> false
    true -> true or &1 * &2
    end
    """

    {:ok, here_ast} =
      here_doc
      |> SortSpec.adapt_string(@sorting_on_structs?)
      |> Code.string_to_quoted()

    {here_fun, []} =
      here_doc
      |> SortSpec.adapt_string(@sorting_on_structs?)
      |> Code.eval_string()

    sort_specs = [:dob, desc: :likes]
    tuple = List.to_tuple(sort_specs)
    tuple_ast = quote do: Tuple.to_list(unquote(tuple))

    setup = %{
      true_doc: true_doc,
      true_ast: true_ast,
      true_fun: true_fun,
      here_doc: here_doc,
      here_ast: here_ast,
      here_fun: here_fun,
      sort_specs: sort_specs,
      tuple: tuple,
      tuple_ast: tuple_ast
    }

    {:ok, setup: setup}
  end

  # :debug → debug, info, warn and error messages (at runtime)
  @level :error

  # mix test --only debug<n>

  describe "SortSpec.to_quoted/1" do
    @tag :debug1
    test "works for compile time sort specs", %{setup: setup} do
      Logger.configure(level: @level)
      {:ok, comp_fun_ast} = SortSpec.to_quoted(setup.sort_specs)
      Logger.configure(level: :error)
      {comp_fun, []} = Code.eval_quoted(comp_fun_ast)
      assert comp_fun_ast == setup.here_ast
      assert match?({:&, _meta, _args}, comp_fun_ast)
      assert match?([_, _], setup.sort_specs)
      assert comp_fun == setup.here_fun
      assert is_function(comp_fun, 2)
    end

    @tag :debug2
    test "works for runtime sort specs", %{setup: setup} do
      Logger.configure(level: @level)
      {:ok, comp_fun_ast} = SortSpec.to_quoted(setup.tuple_ast)
      to_comp_fun = SortSpec.to_comp_fun(setup.sort_specs)
      Logger.configure(level: :error)
      {comp_fun, []} = Code.eval_quoted(comp_fun_ast)
      assert Tuple.to_list(setup.tuple) == setup.sort_specs
      assert comp_fun == to_comp_fun
      assert is_function(comp_fun, 2)
      assert match?({{:., _, _}, _meta, _args}, comp_fun_ast)
      assert match?({{:., _, _}, _meta, _args}, setup.tuple_ast)
    end

    @tag :debug3
    test "works for empty sort specs" do
      sort_specs = []
      Logger.configure(level: @level)
      {:ok, comp_fun_ast} = SortSpec.to_quoted(sort_specs)
      Logger.configure(level: :error)
      assert match?({:&, _meta, _args}, comp_fun_ast)
      assert match?([], sort_specs)
    end

    @tag :debug4
    test "detects bad specs" do
      nil_sort_specs = nil
      map_sort_specs = %{asc: :dob, desc: :likes}
      Logger.configure(level: @level)
      {:error, nil_bad_specs} = SortSpec.to_quoted(nil_sort_specs)
      {:error, map_bad_specs} = SortSpec.to_quoted(map_sort_specs)
      Logger.configure(level: :error)
      assert nil_bad_specs == nil_sort_specs
      assert map_bad_specs == map_sort_specs
    end
  end

  describe "SortSpec.to_comp_fun/1" do
    @tag :debug5
    test "returns a sort function", %{setup: setup} do
      Logger.configure(level: @level)
      comp_fun = SortSpec.to_comp_fun([:dob, desc: :likes])
      Logger.configure(level: :error)
      assert comp_fun == setup.here_fun
      assert is_function(comp_fun, 2)
      assert comp_fun.(%{likes: "ski"}, %{likes: "art"})
      refute comp_fun.(%{likes: "art"}, %{likes: "ski"})
    end

    @tag :debug6
    test ~S[returns a "true" function given bad specs], %{setup: setup} do
      Logger.configure(level: @level)
      tuple_comp_fun = SortSpec.to_comp_fun({:dob, :desc, :likes})
      empty_comp_fun = SortSpec.to_comp_fun([])
      nihil_comp_fun = SortSpec.to_comp_fun(nil)
      Logger.configure(level: :error)
      assert tuple_comp_fun == setup.true_fun
      assert empty_comp_fun == setup.true_fun
      assert nihil_comp_fun == setup.true_fun
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
  end
end
