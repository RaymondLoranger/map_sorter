defmodule MapSorter.ImplTest do
  @moduledoc false

  use ExUnit.Case, async: false

  alias MapSorter.Impl

  @app Mix.Project.config[:app]
  @structs_enabled? Application.get_env(@app, :structs_enabled?)

  doctest Impl

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
      |> Impl.adapt_string(@structs_enabled?)
      |> Code.string_to_quoted()
    {here_fun, []} =
      here_doc
      |> Impl.adapt_string(@structs_enabled?)
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

  describe "Impl.sort_fun/1" do
    test "returns the AST of a sort function", %{setup: setup} do
      Logger.configure(level: :info) # :debug → debug messages
      sort_fun_ast = Impl.sort_fun(setup.sort_specs)
      Logger.configure(level: :info)
      assert sort_fun_ast == setup.here_ast
      assert match?({:&, _meta, _args}, sort_fun_ast)
    end

    test "works for compile time sort specs", %{setup: setup} do
      Logger.configure(level: :info) # :debug → debug messages
      sort_fun_ast = Impl.sort_fun(setup.sort_specs)
      Logger.configure(level: :info)
      {sort_fun, []} = Code.eval_quoted(sort_fun_ast)
      assert sort_fun == setup.here_fun
      assert is_function(sort_fun, 2)
      assert match?({:&, _meta, _args}, sort_fun_ast)
      assert match?([_, _], setup.sort_specs)
    end

    test "works for runtime sort specs", %{setup: setup} do
      Logger.configure(level: :info) # :debug → debug messages
      sort_fun_ast = Impl.sort_fun(setup.tuple_ast)
      eval_sort_fun = Impl.eval_sort_fun(setup.sort_specs)
      Logger.configure(level: :info)
      {sort_fun, []} = Code.eval_quoted(sort_fun_ast)
      assert Tuple.to_list(setup.tuple) == setup.sort_specs
      assert sort_fun == eval_sort_fun
      assert is_function(sort_fun, 2)
      assert match?({{:., _, _}, _meta, _args}, sort_fun_ast)
      assert match?({{:., _, _}, _meta, _args}, setup.tuple_ast)
    end
  end

  describe "Impl.eval_sort_fun/1" do
    test "returns a sort function", %{setup: setup} do
      Logger.configure(level: :info) # :debug → debug messages
      sort_fun = Impl.eval_sort_fun(setup.sort_specs)
      Logger.configure(level: :info)
      assert sort_fun == setup.here_fun
      assert is_function(sort_fun, 2)
    end
  end
end
