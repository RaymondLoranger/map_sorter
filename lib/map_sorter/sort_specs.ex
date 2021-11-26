defmodule MapSorter.SortSpecs do
  use PersistConfig

  @compare_function get_env(:compare_function)

  @moduledoc """
  Generates the AST of a #{@compare_function} from a list of `sort specs`.
  """

  alias MapSorter.{Compare, Log, SortSpec}

  @type t :: [SortSpec.t()]

  @doc """
  Converts `sort specs` into the AST of a #{@compare_function}
  (compile time or runtime).

  ## Examples

      iex> alias MapSorter.SortSpecs
      iex> sort_specs = [:dob, desc: :likes]
      iex> {:ok, comp_fun_ast} = SortSpecs.to_quoted(sort_specs)
      iex> {:&, _meta, [args]} = comp_fun_ast
      iex> Macro.to_string(args)
      \"""
      cond do
        (&1)[:dob] < (&2)[:dob] ->
          true
        (&1)[:dob] > (&2)[:dob] ->
          false
        (&1)[:likes] > (&2)[:likes] ->
          true
        (&1)[:likes] < (&2)[:likes] ->
          false
        true ->
          true or &1 * &2
      end
      \"""
      |> String.trim_trailing()

      iex> alias MapSorter.SortSpecs
      iex> sort_specs = quote do: Tuple.to_list({:dob, {:desc, :likes}})
      iex> {:ok, comp_fun_ast} = SortSpecs.to_quoted(sort_specs)
      iex> {{:., _, _}, _meta, [args]} = comp_fun_ast
      iex> Macro.to_string(args)
      "Tuple.to_list({:dob, {:desc, :likes}})"
  """
  @spec to_quoted(t | Macro.t()) :: {:ok, Macro.t()} | {:error, t}
  def to_quoted(sort_specs) when is_list(sort_specs) do
    Log.debug(:generating_compile_time_comp_fun, {sort_specs, __ENV__})
    {:ok, fun_ast} = Compare.heredoc(sort_specs) |> Code.string_to_quoted()
    :ok = Log.debug(:compile_time_comp_fun_ast, {sort_specs, fun_ast, __ENV__})
    {:ok, fun_ast}
  end

  def to_quoted({:%{}, _, _} = sort_specs) do
    :ok = Log.error(:sort_specs_cannot_be, {sort_specs, "a 'map'", __ENV__})
    {:error, sort_specs}
  end

  def to_quoted({:{}, _, _} = sort_specs) do
    :ok = Log.error(:sort_specs_cannot_be, {sort_specs, "a 'tuple'", __ENV__})
    {:error, sort_specs}
  end

  def to_quoted({_, meta, _} = sort_specs) when is_list(meta) do
    fun_ast = quote do: MapSorter.Compare.fun(unquote(sort_specs))
    Log.debug(:runtime_comp_fun_ast, {sort_specs, fun_ast, __ENV__})
    Process.sleep(50)
    {:ok, fun_ast}
  end

  def to_quoted(sort_specs) when is_map(sort_specs) do
    :ok = Log.error(:sort_specs_cannot_be, {sort_specs, "a 'map'", __ENV__})
    {:error, sort_specs}
  end

  def to_quoted(sort_specs) when is_tuple(sort_specs) do
    :ok = Log.error(:sort_specs_cannot_be, {sort_specs, "a 'tuple'", __ENV__})
    {:error, sort_specs}
  end

  def to_quoted(sort_specs) when is_number(sort_specs) do
    :ok = Log.error(:sort_specs_cannot_be, {sort_specs, "a 'number'", __ENV__})
    {:error, sort_specs}
  end

  def to_quoted(sort_specs) when is_boolean(sort_specs) do
    :ok = Log.error(:sort_specs_cannot_be, {sort_specs, "a 'boolean'", __ENV__})
    {:error, sort_specs}
  end

  def to_quoted(sort_specs) when is_atom(sort_specs) do
    :ok = Log.error(:sort_specs_cannot_be, {sort_specs, "an 'atom'", __ENV__})
    {:error, sort_specs}
  end

  def to_quoted(sort_specs) when is_binary(sort_specs) do
    :ok = Log.error(:sort_specs_cannot_be, {sort_specs, "a 'binary'", __ENV__})
    {:error, sort_specs}
  end

  def to_quoted(sort_specs) do
    :ok = Log.error(:sort_specs_cannot_be, {sort_specs, "a 'literal'", __ENV__})
    {:error, sort_specs}
  end
end
