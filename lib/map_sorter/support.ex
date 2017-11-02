defmodule MapSorter.Support do
  @moduledoc """
  Generates a sort function from a list of `sort specs`.
  """

  require Logger

  @type sort_dir :: :asc | :desc
  @type sort_fun :: (map, map -> boolean)
  @type sort_spec :: any | {sort_dir, any}

  @doc """
  Takes a list of `sort specs` (ascending/descending keys).

  Returns the AST of a sort function based on the given `sort specs`
  allowing to sort a list of `maps`¹.

  The sort function will compare two `maps`¹ and return true
  if the first `map` precedes the second one.

  **--Or--**

  Takes the AST of an expression that will evaluate at runtime
  to a list of `sort specs` (ascending/descending keys).

  Returns the AST of a function call to evaluate the sort function
  at runtime.

  ¹_Or keywords or structures implementing the Access behaviour._

  ## Examples

      iex> alias MapSorter.Support
      iex> Logger.configure(level: :info) # :debug => debug messages
      iex> sort_fun_ast = Support.sort_fun_ast([:height, desc: :likes])
      iex> Logger.configure(level: :info) # :info => no debug messages
      iex> here_string =
      ...>   \"""
      ...>   & cond do
      ...>   &1[:height] < &2[:height] -> true
      ...>   &1[:height] > &2[:height] -> false
      ...>   &1[:likes] > &2[:likes] -> true
      ...>   &1[:likes] < &2[:likes] -> false
      ...>   true -> true
      ...>   end
      ...>   \"""
      iex> {:ok, here_ast} =
      ...>   here_string
      ...>   |> Support.adapted_string()
      ...>   |> Code.string_to_quoted()
      iex> sort_fun_ast == here_ast and
      ...> match?({:&, _meta, _args}, sort_fun_ast)
      true

      iex> alias MapSorter.Support
      iex> Logger.configure(level: :info) # :debug => debug messages
      iex> {sort_fun, []} =
      iex>   [:weight, desc: :likes]
      ...>   |> Support.sort_fun_ast()
      ...>   |> Code.eval_quoted()
      iex> Logger.configure(level: :info) # :info => no debug messages
      iex> here_string =
      ...>   \"""
      ...>   & cond do
      ...>   &1[:weight] < &2[:weight] -> true
      ...>   &1[:weight] > &2[:weight] -> false
      ...>   &1[:likes] > &2[:likes] -> true
      ...>   &1[:likes] < &2[:likes] -> false
      ...>   true -> true
      ...>   end
      ...>   \"""
      iex> {here_fun, []} =
      ...>   here_string
      ...>   |> Support.adapted_string()
      ...>   |> Code.eval_string()
      iex> sort_fun == here_fun and
      ...> is_function(sort_fun, 2)
      true

      iex> alias MapSorter.Support
      iex> sort_specs_ast = quote do: Tuple.to_list({:dept, {:desc, :dob}})
      iex> Logger.configure(level: :info) # :debug => debug messages
      iex> {sort_fun, []} =
      ...>   sort_specs_ast
      ...>   |> Support.sort_fun_ast()
      ...>   |> Code.eval_quoted()
      iex> eval_sort_fun = Support.eval_sort_fun([:dept, desc: :dob])
      iex> Logger.configure(level: :info) # :info => no debug messages
      iex> Tuple.to_list({:dept, {:desc, :dob}}) == [:dept, desc: :dob] and
      ...> sort_fun == eval_sort_fun and
      ...> is_function(sort_fun, 2)
      true
  """
  @spec sort_fun_ast([sort_spec]) :: {:&, any, any}
  def sort_fun_ast(sort_specs) when is_list(sort_specs) do
    Logger.debug("expanding: sort_fun_ast(#{inspect(sort_specs)})...")
    {:ok, sort_fun_ast} =
      sort_specs
      |> cond_fun_string()
      |> Code.string_to_quoted()
    sort_fun_ast
  end

  @spec sort_fun_ast({any, any, any}) :: {{:., any, any}, any, any}
  def sort_fun_ast(sort_specs_ast) do
    Logger.debug("injecting: eval_sort_fun(#{inspect(sort_specs_ast)})...")
    quote do: MapSorter.Support.eval_sort_fun(unquote(sort_specs_ast))
  end

  @doc """
  Takes a list of `sort specs` (ascending/descending keys).

  Returns a sort function based on the given `sort specs` which compares
  two `maps`¹ and returns true if the first `map` precedes the second one.

  ¹_Or keywords or structures implementing the Access behaviour._

  ## Examples

      iex> alias MapSorter.Support
      iex> Logger.configure(level: :info) # :debug => debug messages
      iex> sort_fun = Support.eval_sort_fun([:bmi, desc: :likes])
      iex> Logger.configure(level: :info) # :info => no debug messages
      iex> here_string =
      ...>   \"""
      ...>   & cond do
      ...>   &1[:bmi] < &2[:bmi] -> true
      ...>   &1[:bmi] > &2[:bmi] -> false
      ...>   &1[:likes] > &2[:likes] -> true
      ...>   &1[:likes] < &2[:likes] -> false
      ...>   true -> true
      ...>   end
      ...>   \"""
      iex> {here_fun, []} =
      ...>   here_string
      ...>   |> Support.adapted_string()
      ...>   |> Code.eval_string()
      iex> sort_fun == here_fun and
      ...> is_function(sort_fun, 2)
      true
  """
  @spec eval_sort_fun([sort_spec]) :: sort_fun
  def eval_sort_fun(sort_specs) when is_list(sort_specs) do
    Logger.debug("running: eval_sort_fun(#{inspect(sort_specs)})...")
    {sort_fun, []} =
      sort_specs
      |> cond_fun_string()
      |> Code.eval_string()
    sort_fun
  end

  @spec cond_fun_string([sort_spec]) :: String.t
  defp cond_fun_string(sort_specs) do
    cond_clauses_string =
      sort_specs
      |> Enum.map_join(&cond_clauses_string/1)
      |> String.trim_trailing()
      |> adapted_string()
    here_string =
      """
      & cond do
      #{cond_clauses_string}
      true -> true
      end
      """
    Logger.debug(here_string)
    here_string
  end

  @spec cond_clauses_string(sort_spec) :: String.t
  defp cond_clauses_string({:asc, key}) do
    """
    &1[#{inspect(key)}] < &2[#{inspect(key)}] -> true
    &1[#{inspect(key)}] > &2[#{inspect(key)}] -> false
    """
  end
  defp cond_clauses_string({:desc, key}) do
    """
    &1[#{inspect(key)}] > &2[#{inspect(key)}] -> true
    &1[#{inspect(key)}] < &2[#{inspect(key)}] -> false
    """
  end
  defp cond_clauses_string(key), do: cond_clauses_string({:asc, key})

  @doc """
  Adapts a string to invoke the `sortable/1` function.

  ## Examples

      iex> alias MapSorter.Support
      iex> Support.adapted_string(
      ...>   \"""
      ...>   &1[:bmi]
      ...>   &1[:sex]
      ...>   \"""
      ...> )
      \"""
      MapSorter.Support.sortable(&1[:bmi])
      MapSorter.Support.sortable(&1[:sex])
      \"""
  """
  @spec adapted_string(String.t) :: String.t
  def adapted_string(string) do
    String.replace(string, ~r/(&[12].+?])/, "MapSorter.Support.sortable(\\1)")
  end

  @doc """
  Converts a value to a sortable format, if needed.

  ## Examples

      iex> alias MapSorter.Support
      iex> Support.sortable(~D[2017-11-01])
      "2017-11-01"

      iex> alias MapSorter.Support
      iex> Support.sortable(~T[15:41:33])
      "15:41:33"

      iex> alias MapSorter.Support
      iex> Support.sortable(3.1416)
      3.1416

      iex> alias MapSorter.Support
      iex> Support.sortable(%{z: 26, y: 25, a: 1})
      %{z: 26, y: 25, a: 1}
  """
  @spec sortable(any) :: String.t | any
  def sortable(%Date{} = value), do: Date.to_string(value)
  def sortable(%DateTime{} = value), do: DateTime.to_string(value)
  def sortable(%NaiveDateTime{} = value), do: NaiveDateTime.to_string(value)
  def sortable(%Time{} = value), do: Time.to_string(value)
  def sortable(value), do: value
end
