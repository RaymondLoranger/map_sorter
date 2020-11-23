defmodule MapSorter.SortSpecs do
  use PersistConfig

  @compare_function get_env(:compare_function)

  @moduledoc """
  Generates the AST of a #{@compare_function} from a list of `sort specs`.
  """

  alias MapSorter.{Compare, Log, SortSpec}

  @type t :: [SortSpec.t()]

  @doc """
  Converts `sort specs` to the AST of a #{@compare_function}
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
    Log.debug(:generating_compile_time_comp_fun, {__ENV__, sort_specs})
    {:ok, fun_ast} = sort_specs |> Compare.heredoc() |> Code.string_to_quoted()
    :ok = Log.debug(:compile_time_comp_fun_ast, {__ENV__, sort_specs, fun_ast})
    {:ok, fun_ast}
  end

  def to_quoted({:%{}, _, _} = sort_specs) do
    :ok = Log.warn(:sort_specs_cannot_be, {__ENV__, sort_specs, "a 'map'"})
    {:error, sort_specs}
  end

  def to_quoted({:{}, _, _} = sort_specs) do
    :ok = Log.warn(:sort_specs_cannot_be, {__ENV__, sort_specs, "a 'tuple'"})
    {:error, sort_specs}
  end

  def to_quoted({_, meta, _} = sort_specs) when is_list(meta) do
    fun_ast = quote do: MapSorter.Compare.fun(unquote(sort_specs))
    :ok = Log.debug(:runtime_comp_fun_ast, {__ENV__, sort_specs, fun_ast})
    {:ok, fun_ast}
  end

  def to_quoted(sort_specs) when is_map(sort_specs) do
    :ok = Log.warn(:sort_specs_cannot_be, {__ENV__, sort_specs, "a 'map'"})
    {:error, sort_specs}
  end

  def to_quoted(sort_specs) when is_tuple(sort_specs) do
    :ok = Log.warn(:sort_specs_cannot_be, {__ENV__, sort_specs, "a 'tuple'"})
    {:error, sort_specs}
  end

  def to_quoted(sort_specs) when is_number(sort_specs) do
    :ok = Log.warn(:sort_specs_cannot_be, {__ENV__, sort_specs, "a 'number'"})
    {:error, sort_specs}
  end

  def to_quoted(sort_specs) when is_boolean(sort_specs) do
    :ok = Log.warn(:sort_specs_cannot_be, {__ENV__, sort_specs, "a 'boolean'"})
    {:error, sort_specs}
  end

  def to_quoted(sort_specs) when is_atom(sort_specs) do
    :ok = Log.warn(:sort_specs_cannot_be, {__ENV__, sort_specs, "an 'atom'"})
    {:error, sort_specs}
  end

  def to_quoted(sort_specs) when is_binary(sort_specs) do
    :ok = Log.warn(:sort_specs_cannot_be, {__ENV__, sort_specs, "a 'binary'"})
    {:error, sort_specs}
  end

  def to_quoted(sort_specs) do
    :ok = Log.warn(:sort_specs_cannot_be, {__ENV__, sort_specs, "a 'literal'"})
    {:error, sort_specs}
  end
end
