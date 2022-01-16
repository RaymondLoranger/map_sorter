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

      # Compile time sort specs...
      iex> alias MapSorter.SortSpecs
      iex> sort_specs = [:dob]
      iex> {:ok, comp_fun_ast} = SortSpecs.to_quoted(sort_specs)
      iex> {:&, _meta, [args]} = comp_fun_ast
      iex> {comp_fun, []} = Code.eval_quoted(comp_fun_ast)
      iex> is_function(comp_fun, 2) and Macro.to_string(args)
      """
      cond do
        &1[:dob] < &2[:dob] -> true
        &1[:dob] > &2[:dob] -> false
        true -> true or &1 * &2
      end
      """
      |> String.trim_trailing()

      # Compile time sort specs...
      iex> alias MapSorter.SortSpecs
      iex> key_field = fn -> :dob end
      iex> sort_specs = [key_field.()]
      iex> {:ok, comp_fun_ast} = SortSpecs.to_quoted(sort_specs)
      iex> {:&, _meta, [args]} = comp_fun_ast
      iex> {comp_fun, []} = Code.eval_quoted(comp_fun_ast)
      iex> is_function(comp_fun, 2) and Macro.to_string(args)
      """
      cond do
        &1[:dob] < &2[:dob] -> true
        &1[:dob] > &2[:dob] -> false
        true -> true or &1 * &2
      end
      """
      |> String.trim_trailing()

      # Compile time sort specs...
      iex> alias MapSorter.SortSpecs
      iex> sort_specs = [:dob, desc: :likes]
      iex> {:ok, comp_fun_ast} = SortSpecs.to_quoted(sort_specs)
      iex> {:&, _meta, [args]} = comp_fun_ast
      iex> {comp_fun, []} = Code.eval_quoted(comp_fun_ast)
      iex> is_function(comp_fun, 2) and Macro.to_string(args)
      """
      cond do
        &1[:dob] < &2[:dob] -> true
        &1[:dob] > &2[:dob] -> false
        &1[:likes] > &2[:likes] -> true
        &1[:likes] < &2[:likes] -> false
        true -> true or &1 * &2
      end
      """
      |> String.trim_trailing()

      # Runtime sort specs...
      iex> alias MapSorter.SortSpecs
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
    :ok = Log.debug(:generating_compile_time_heredoc, {sort_specs, __ENV__})
    {:ok, fun_ast} = Compare.heredoc(sort_specs) |> Code.string_to_quoted()
    :ok = Log.debug(:compile_time_comp_fun_ast, {sort_specs, fun_ast, __ENV__})
    {:ok, fun_ast}
  end

  # Sort specs cannot be a map...
  def to_quoted({:%{}, _, _} = sort_specs) do
    :ok = Log.warn(:invalid_specs, {sort_specs, __ENV__})
    {:error, sort_specs}
  end

  # Sort specs cannot be a tuple...
  def to_quoted({:{}, _, _} = sort_specs) do
    :ok = Log.warn(:invalid_specs, {sort_specs, __ENV__})
    {:error, sort_specs}
  end

  # Sort specs evaluated at runtime...
  def to_quoted({_, meta, _} = sort_specs) when is_list(meta) do
    # Injected code should refer to a function by its fully qualified name...
    fun_ast = quote do: MapSorter.Compare.fun(unquote(sort_specs))
    :ok = Log.debug(:runtime_comp_fun_ast, {sort_specs, fun_ast, __ENV__})
    {:ok, fun_ast}
  end

  # Sort specs cannot be other terms...
  def to_quoted(sort_specs) do
    :ok = Log.warn(:invalid_specs, {sort_specs, __ENV__})
    {:error, sort_specs}
  end
end
