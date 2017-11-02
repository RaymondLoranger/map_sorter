defmodule MapSorter.Support do
  @moduledoc """
  Generates a sort function from a list of `sort specs`
  (ascending/descending keys).
  """

  require Logger

  @type sort_dir :: :asc | :desc
  @type sort_fun :: (map, map -> boolean)
  @type sort_spec :: any | {sort_dir, any}

  @doc """
  Returns the AST of a sort function based on the given `sort specs`
  (compile time or runtime).

  ## Examples

      iex> alias MapSorter.Support
      iex> Logger.configure(level: :info) # :debug → debug messages
      iex> sort_fun_ast = Support.sort_fun_ast([:dob, desc: :likes])
      iex> Logger.configure(level: :info) # :info → no debug messages
      iex> match?({:&, _meta, _args}, sort_fun_ast)
      true

      iex> alias MapSorter.Support
      iex> sort_specs_ast = quote do: Tuple.to_list({:dob, {:desc, :likes}})
      iex> Logger.configure(level: :info) # :debug → debug messages
      iex> sort_fun_ast = Support.sort_fun_ast(sort_specs_ast)
      iex> Logger.configure(level: :info) # :info → no debug messages
      iex> match?({{:., _, _}, _meta, _args}, sort_fun_ast)
      true
  """
  @spec sort_fun_ast([sort_spec] | {any, any, any}) :: {any, any, any}
  def sort_fun_ast(sort_specs) when is_list(sort_specs) do
    Logger.debug("expanding: sort_fun_ast(#{inspect(sort_specs)})...")
    {:ok, sort_fun_ast} =
      sort_specs
      |> cond_fun_doc()
      |> Code.string_to_quoted()
    sort_fun_ast
  end
  def sort_fun_ast(sort_specs_ast) do
    Logger.debug("injecting: eval_sort_fun(#{inspect(sort_specs_ast)})...")
    quote do: MapSorter.Support.eval_sort_fun(unquote(sort_specs_ast))
  end

  @doc """
  Returns a sort function based on the given `sort specs`.

  ## Examples

      iex> alias MapSorter.Support
      iex> Logger.configure(level: :info) # :debug → debug messages
      iex> sort_fun = Support.eval_sort_fun([:dob, desc: :likes])
      iex> Logger.configure(level: :info) # :info → no debug messages
      iex> is_function(sort_fun, 2)
      true
  """
  @spec eval_sort_fun([sort_spec]) :: sort_fun
  def eval_sort_fun(sort_specs) when is_list(sort_specs) do
    Logger.debug("running: eval_sort_fun(#{inspect(sort_specs)})...")
    {sort_fun, []} =
      sort_specs
      |> cond_fun_doc()
      |> Code.eval_string()
    sort_fun
  end

  @spec cond_fun_doc([sort_spec]) :: String.t
  defp cond_fun_doc(sort_specs) do
    cond_clauses_doc =
      sort_specs
      |> Enum.map_join(&cond_clauses_doc/1)
      |> String.trim_trailing()
      |> adapt()
    here_doc =
      """
      & cond do
      #{cond_clauses_doc}
      true -> true
      end
      """
    Logger.debug(here_doc)
    here_doc
  end

  @spec cond_clauses_doc(sort_spec) :: String.t
  defp cond_clauses_doc({:asc, key}) do
    key = inspect(key)
    """
    &1[#{key}] < &2[#{key}] -> true
    &1[#{key}] > &2[#{key}] -> false
    """
  end
  defp cond_clauses_doc({:desc, key}) do
    key = inspect(key)
    """
    &1[#{key}] > &2[#{key}] -> true
    &1[#{key}] < &2[#{key}] -> false
    """
  end
  defp cond_clauses_doc(key), do: cond_clauses_doc({:asc, key})

  @doc """
  Adapts the given `string` to invoke the `sortable/1` function.

  ## Examples

      iex> alias MapSorter.Support
      iex> Support.adapt(
      ...>   \"""
      ...>   &1[:dob] < ...
      ...>   &2[:likes] -> ...
      ...>   \"""
      ...> )
      \"""
      MapSorter.Support.sortable(&1[:dob]) < ...
      MapSorter.Support.sortable(&2[:likes]) -> ...
      \"""
  """
  @spec adapt(String.t) :: String.t
  def adapt(string) do
    # &1[~D[2017-11-02]] < &2[~D[2017-11-02]] -> true
    regex = ~r/(&[12]\[.+?])( +[<>-])/
    String.replace(string, regex, "MapSorter.Support.sortable(\\1)\\2")
  end

  @doc """
  Converts a value to a sortable format, if needed.

  ## Examples

      iex> alias MapSorter.Support
      iex> Support.sortable(~T[15:41:33])
      "15:41:33"

      iex> alias MapSorter.Support
      iex> Support.sortable(3.1416)
      3.1416
  """
  @spec sortable(any) :: any
  def sortable(%Date{} = value), do: Date.to_string(value)
  def sortable(%DateTime{} = value), do: DateTime.to_string(value)
  def sortable(%NaiveDateTime{} = value), do: NaiveDateTime.to_string(value)
  def sortable(%Time{} = value), do: Time.to_string(value)
  def sortable(value), do: value
end
