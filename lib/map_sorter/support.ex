defmodule MapSorter.Support do
  @moduledoc """
  Generates a sort function from a list of `sort specs`.
  """

  require Logger

  @type sort_dir :: :asc | :desc
  @type sort_fun :: (map, map -> boolean)
  @type sort_spec :: Map.key | {sort_dir, Map.key}

  @doc """
  Takes a list of `sort specs` (ascending/descending keys).

  Returns the AST of a sort function based on the given `sort specs`
  allowing to sort a list of `maps`¹ (compile time expansion).

  The sort function will compare two `maps`¹ and return true
  if the first `map` precedes the second one.

  **--Or--**

  Takes the AST of an expression that will evaluate at runtime
  to a list of `sort specs` (ascending/descending keys).

  Returns the AST of a function call to evaluate the sort function
  at runtime (compile time injection).

  ¹__Also keywords or structures implementing the Access behaviour.__

  ## Examples

      iex> alias MapSorter.Support
      iex> Logger.configure(level: :info) # :debug ⇒ debug messages
      iex> sort_fun_ast = Support.sort_fun_ast([:height, desc: :likes])
      iex> Logger.configure(level: :info) # :info ⇒ no debug messages
      iex> here_doc = \"""
      ...>   & cond do
      ...>   &1[:height] < &2[:height] -> true
      ...>   &1[:height] > &2[:height] -> false
      ...>   &1[:likes] > &2[:likes] -> true
      ...>   &1[:likes] < &2[:likes] -> false
      ...>   true -> true
      ...>   end
      ...>   \"""
      iex> {:ok, here_ast} = Code.string_to_quoted(here_doc)
      iex> sort_fun_ast == here_ast and
      ...> match?({:&, _meta, _args}, sort_fun_ast)
      true

      iex> alias MapSorter.Support
      iex> Logger.configure(level: :info) # :debug ⇒ debug messages
      iex> {sort_fun, []} =
      iex>   [:weight, desc: :likes]
      ...>   |> Support.sort_fun_ast()
      ...>   |> Code.eval_quoted()
      iex> Logger.configure(level: :info) # :info ⇒ no debug messages
      iex> here_doc = \"""
      ...>   & cond do
      ...>   &1[:weight] < &2[:weight] -> true
      ...>   &1[:weight] > &2[:weight] -> false
      ...>   &1[:likes] > &2[:likes] -> true
      ...>   &1[:likes] < &2[:likes] -> false
      ...>   true -> true
      ...>   end
      ...>   \"""
      iex> {here_fun, []} = Code.eval_string(here_doc)
      iex> sort_fun == here_fun and
      ...> is_function(sort_fun, 2)
      true
  """
  @spec sort_fun_ast([sort_spec]) :: {:&, any, any}
  def sort_fun_ast(sort_specs) when is_list(sort_specs) do
    Logger.debug("expanding: sort_fun_ast(#{inspect sort_specs})...")
    {:ok, sort_fun_ast} =
      sort_specs
      |> cond_fun()
      |> Code.string_to_quoted()
    sort_fun_ast
  end

  @spec sort_fun_ast({any, any, any}) :: {{:., any, any}, any, any}
  def sort_fun_ast(sort_specs_ast) do
    Logger.debug(":injecting: eval_sort_fun(#{inspect sort_specs_ast})...")
    quote do: MapSorter.Support.eval_sort_fun(unquote(sort_specs_ast))
  end

  @doc """
  Takes a list of `sort specs` (ascending/descending keys).

  Returns a sort function based on the given `sort specs` that compares
  two `maps`¹ and returns true if the first `map` precedes the second one.

  ¹__Also keywords or structures implementing the Access behaviour.__

  ## Examples

      iex> alias MapSorter.Support
      iex> Logger.configure(level: :info) # :debug ⇒ debug messages
      iex> sort_fun = Support.eval_sort_fun([:bmi, desc: :likes])
      iex> Logger.configure(level: :info) # :info ⇒ no debug messages
      iex> here_doc =
      ...>   \"""
      ...>   & cond do
      ...>   &1[:bmi] < &2[:bmi] -> true
      ...>   &1[:bmi] > &2[:bmi] -> false
      ...>   &1[:likes] > &2[:likes] -> true
      ...>   &1[:likes] < &2[:likes] -> false
      ...>   true -> true
      ...>   end
      ...>   \"""
      iex> {here_fun, []} = Code.eval_string(here_doc)
      iex> sort_fun == here_fun and
      ...> is_function(sort_fun, 2)
      true
  """
  @spec eval_sort_fun([sort_spec]) :: sort_fun
  def eval_sort_fun(sort_specs) when is_list(sort_specs) do
    Logger.debug("running: eval_sort_fun(#{inspect sort_specs})...")
    {sort_fun, []} =
      sort_specs
      |> cond_fun()
      |> Code.eval_string()
    sort_fun
  end

  @spec cond_fun([sort_spec]) :: String.t
  defp cond_fun(sort_specs) do
    cond_clauses =
      sort_specs
      |> Enum.map_join(&cond_clauses/1)
      |> String.trim_trailing()
    here_doc =
      """
      & cond do
      #{cond_clauses}
      true -> true
      end
      """
    Logger.debug(here_doc)
    here_doc
  end

  @spec cond_clauses(sort_spec) :: String.t

  defp cond_clauses({:asc, key}) do
    """
    &1[#{inspect key}] < &2[#{inspect key}] -> true
    &1[#{inspect key}] > &2[#{inspect key}] -> false
    """
  end

  defp cond_clauses({:desc, key}) do
    """
    &1[#{inspect key}] > &2[#{inspect key}] -> true
    &1[#{inspect key}] < &2[#{inspect key}] -> false
    """
  end

  defp cond_clauses(key), do: cond_clauses({:asc, key})
end
