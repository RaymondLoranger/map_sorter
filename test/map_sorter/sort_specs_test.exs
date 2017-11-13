defmodule MapSorter.SortSpecsTest do
  @moduledoc false

  use ExUnit.Case, async: false

  alias MapSorter.SortSpecs

  @app Mix.Project.config[:app]
  @structs_enabled? Application.get_env(@app, :structs_enabled?)

  doctest SortSpecs

  setup_all do
    here_doc =
      """
      & cond do
      &1[:dob] < &2[:dob] -> true
      &1[:dob] > &2[:dob] -> false
      &1[:likes] > &2[:likes] -> true
      &1[:likes] < &2[:likes] -> false
      true -> true
      end
      """
    {:ok, here_ast} =
      here_doc
      |> SortSpecs.adapt_string(@structs_enabled?)
      |> Code.string_to_quoted()
    {here_fun, []} =
      here_doc
      |> SortSpecs.adapt_string(@structs_enabled?)
      |> Code.eval_string()
    sort_specs = [:dob, desc: :likes]
    tuple = List.to_tuple(sort_specs)
    tuple_ast = quote do: Tuple.to_list(unquote(tuple))
    setup = %{
      here_doc:   here_doc,
      here_ast:   here_ast,
      here_fun:   here_fun,
      sort_specs: sort_specs,
      tuple:      tuple,
      tuple_ast:  tuple_ast
    }
    {:ok, setup: setup}
  end

  describe "SortSpecs.to_quoted/1" do
    test "returns the AST of a sort function", %{setup: setup} do
      Logger.configure(level: :info) # :debug → debug messages
      {:ok, comp_fun_ast} = SortSpecs.to_quoted(setup.sort_specs)
      Logger.configure(level: :info)
      assert comp_fun_ast == setup.here_ast
      assert match?({:&, _meta, _args}, comp_fun_ast)
    end

    test "works for compile time sort specs", %{setup: setup} do
      Logger.configure(level: :info) # :debug → debug messages
      {:ok, comp_fun_ast} = SortSpecs.to_quoted(setup.sort_specs)
      Logger.configure(level: :info)
      {comp_fun, []} = Code.eval_quoted(comp_fun_ast)
      assert comp_fun == setup.here_fun
      assert is_function(comp_fun, 2)
      assert match?({:&, _meta, _args}, comp_fun_ast)
      assert match?([_, _], setup.sort_specs)
    end

    test "works for runtime sort specs", %{setup: setup} do
      Logger.configure(level: :info) # :debug → debug messages
      {:ok, comp_fun_ast} = SortSpecs.to_quoted(setup.tuple_ast)
      to_comp_fun = SortSpecs.to_comp_fun(setup.sort_specs)
      Logger.configure(level: :info)
      {comp_fun, []} = Code.eval_quoted(comp_fun_ast)
      assert Tuple.to_list(setup.tuple) == setup.sort_specs
      assert comp_fun == to_comp_fun
      assert is_function(comp_fun, 2)
      assert match?({{:., _, _}, _meta, _args}, comp_fun_ast)
      assert match?({{:., _, _}, _meta, _args}, setup.tuple_ast)
    end
  end

  describe "SortSpecs.to_comp_fun/1" do
    test "returns a sort function", %{setup: setup} do
      Logger.configure(level: :info) # :debug → debug messages
      to_comp_fun = SortSpecs.to_comp_fun(setup.sort_specs)
      Logger.configure(level: :info)
      assert to_comp_fun == setup.here_fun
      assert is_function(to_comp_fun, 2)
    end
  end
end
