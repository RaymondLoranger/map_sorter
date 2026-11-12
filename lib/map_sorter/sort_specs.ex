defmodule MapSorter.SortSpecs do
  @moduledoc """
  Converts the AST of sort specs into the AST of an `Enum.sort/2` compare
  function.
  """

  alias MapSorter.{Compare, Log, SortSpec}

  @typedoc "A list of sort specs"
  @type t :: [SortSpec.t()]

  @doc ~S'''
  Converts `sort_specs` into the AST of an `Enum.sort/2` compare function.

  ## Examples

      # To run multiple doctests sequentially, remove empty lines between them.
      iex> alias MapSorter.{SortSpecs, Log}
      iex> Log.debug(:doctest_id, {:sort_specs_id_1, __ENV__})
      iex> sort_specs = [:dob]
      iex> {:ok, comp_fun_ast} = SortSpecs.to_quoted(sort_specs)
      iex> {:&, _meta, [args]} = comp_fun_ast
      iex> {comp_fun, []} = Code.eval_quoted(comp_fun_ast)
      iex> is_function(comp_fun, 2) and Macro.to_string(args)
      """
      cond do
        &1[:dob] < &2[:dob] -> true
        &1[:dob] > &2[:dob] -> false
        true -> true or &1 > &2
      end\
      """
      iex> alias MapSorter.{SortSpecs, Log}
      iex> Log.debug(:doctest_id, {:sort_specs_id_2, __ENV__})
      iex> sort_specs = fn -> [desc: :dob, asc: :bmi] end
      iex> {:ok, comp_fun_ast} = sort_specs.() |> SortSpecs.to_quoted()
      iex> {:&, _meta, [args]} = comp_fun_ast
      iex> {comp_fun, []} = Code.eval_quoted(comp_fun_ast)
      iex> is_function(comp_fun, 2) and Macro.to_string(args)
      """
      cond do
        &1[:dob] > &2[:dob] -> true
        &1[:dob] < &2[:dob] -> false
        &1[:bmi] < &2[:bmi] -> true
        &1[:bmi] > &2[:bmi] -> false
        true -> true or &1 > &2
      end\
      """
      iex> alias MapSorter.{SortSpecs, Log}
      iex> Log.debug(:doctest_id, {:sort_specs_id_3, __ENV__})
      iex> {:ok, comp_fun_ast} = SortSpecs.to_quoted([:dob, desc: :likes])
      iex> {:&, _meta, [args]} = comp_fun_ast
      iex> {comp_fun, []} = Code.eval_quoted(comp_fun_ast)
      iex> is_function(comp_fun, 2) and Macro.to_string(args)
      """
      cond do
        &1[:dob] < &2[:dob] -> true
        &1[:dob] > &2[:dob] -> false
        &1[:likes] > &2[:likes] -> true
        &1[:likes] < &2[:likes] -> false
        true -> true or &1 > &2
      end\
      """
      iex> alias MapSorter.{SortSpecs, Log}
      iex> Log.debug(:doctest_id, {:sort_specs_id_4, __ENV__})
      iex> sort_specs = quote do: Tuple.to_list({:dob, {:desc, :likes}})
      iex> {:ok, comp_fun_ast} = SortSpecs.to_quoted(sort_specs)
      iex> {{:., _, nested_args}, _meta, [args]} = comp_fun_ast
      iex> {comp_fun, []} = Code.eval_quoted(comp_fun_ast)
      iex> is_function(comp_fun, 2) and
      ...> {Macro.to_string(nested_args), Macro.to_string(args)}
      {"[MapSorter.Compare, :fun]", "Tuple.to_list({:dob, {:desc, :likes}})"}
  '''
  @spec to_quoted(t | Macro.t()) :: {:ok, Macro.t()} | {:error, Macro.t()}
  def to_quoted(sort_specs) when is_list(sort_specs) do
    {:ok, fun_ast} = Compare.heredoc(sort_specs) |> Code.string_to_quoted()
    Log.debug(:heredoc_comp_fun_ast, {sort_specs, fun_ast, __ENV__})
    {:ok, fun_ast}
  end

  # Sort specs cannot be a map...
  def to_quoted({:%{}, _, _} = sort_specs) do
    {:error, sort_specs}
  end

  # Sort specs cannot be a tuple...
  def to_quoted({:{}, _, _} = sort_specs) do
    {:error, sort_specs}
  end

  # Sort specs evaluated at runtime...
  def to_quoted({_, meta, _} = sort_specs) when is_list(meta) do
    # Injected code should refer to a function by its fully qualified name
    # because that code executes within the context of the caller's module.
    fun_ast = quote do: MapSorter.Compare.fun(unquote(sort_specs))
    Log.debug(:runtime_comp_fun_call_ast, {sort_specs, fun_ast, __ENV__})
    {:ok, fun_ast}
  end

  # Sort specs cannot be other terms...
  def to_quoted(sort_specs) do
    {:error, sort_specs}
  end
end
