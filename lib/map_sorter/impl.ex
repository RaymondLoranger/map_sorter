defmodule MapSorter.Impl do
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

      iex> alias MapSorter.Impl
      iex> sort_specs = [:dob, desc: :likes]
      iex> Logger.configure(level: :info) # :debug → debug messages
      iex> sort_fun = Impl.sort_fun(sort_specs)
      iex> Logger.configure(level: :info)
      iex> match?({:&, _meta, _args}, sort_fun) and
      iex> match?([_, _], sort_specs)
      true

      iex> alias MapSorter.Impl
      iex> sort_specs = quote do: Tuple.to_list({:dob, {:desc, :likes}})
      iex> Logger.configure(level: :info) # :debug → debug messages
      iex> sort_fun = Impl.sort_fun(sort_specs)
      iex> Logger.configure(level: :info)
      iex> match?({{:., _, _}, _meta, _args}, sort_fun) and
      iex> match?({{:., _, _}, _meta, _args}, sort_specs)
      true
  """
  @spec sort_fun([sort_spec] | Macro.expr) :: Macro.expr
  def sort_fun(sort_specs) when is_list(sort_specs) do
    Logger.debug("expanding: sort_fun(#{inspect(sort_specs)})...")
    {:ok, sort_fun} =
      sort_specs
      |> cond_fun()
      |> Code.string_to_quoted()
    sort_fun
  end
  def sort_fun(sort_specs) do
    Logger.debug("injecting: eval_sort_fun(#{inspect(sort_specs)})...")
    quote do: MapSorter.Impl.eval_sort_fun(unquote(sort_specs))
  end

  @doc """
  Returns a sort function based on the given `sort specs`.

  ## Examples

      iex> alias MapSorter.Impl
      iex> Logger.configure(level: :info) # :debug → debug messages
      iex> sort_fun = Impl.eval_sort_fun([:dob, desc: :likes])
      iex> Logger.configure(level: :info)
      iex> is_function(sort_fun, 2)
      true
  """
  @spec eval_sort_fun([sort_spec]) :: sort_fun
  def eval_sort_fun(sort_specs) when is_list(sort_specs) do
    Logger.debug("running: eval_sort_fun(#{inspect(sort_specs)})...")
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
      |> adapt()
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
    key = inspect(key)
    """
    &1[#{key}] < &2[#{key}] -> true
    &1[#{key}] > &2[#{key}] -> false
    """
  end
  defp cond_clauses({:desc, key}) do
    key = inspect(key)
    """
    &1[#{key}] > &2[#{key}] -> true
    &1[#{key}] < &2[#{key}] -> false
    """
  end
  defp cond_clauses(key), do: cond_clauses({:asc, key})

  @doc """
  Adapts the given `string` to invoke the `comparable/1` function.

  ## Examples

      iex> alias MapSorter.Impl
      iex> Impl.adapt(
      ...>   \"""
      ...>   &1[:dob] < ...
      ...>   &2[:likes] -> ...
      ...>   \"""
      ...> )
      \"""
      MapSorter.Impl.comparable(&1[:dob]) < ...
      MapSorter.Impl.comparable(&2[:likes]) -> ...
      \"""
  """
  @spec adapt(String.t) :: String.t
  def adapt(string) do
    # &1[~D[2017-11-02]] < &2[~D[2017-11-02]] -> true
    regex = ~r/(&[12]\[.+?])( +[<>-])/
    String.replace(string, regex, "MapSorter.Impl.comparable(\\1)\\2")
  end

  @doc """
  Converts a `value` to a comparable format, if needed.

  ## Examples

      iex> alias MapSorter.Impl
      iex> Impl.comparable(~T[15:41:33])
      "15:41:33"

      iex> alias MapSorter.Impl
      iex> Impl.comparable(3.1416)
      3.1416
  """
  @spec comparable(any) :: any
  def comparable(%Date{} = value), do: Date.to_string(value)
  def comparable(%DateTime{} = value), do: DateTime.to_string(value)
  def comparable(%NaiveDateTime{} = value), do: NaiveDateTime.to_string(value)
  def comparable(%Time{} = value), do: Time.to_string(value)
  def comparable(%Version{} = value), do: to_string(value)
  def comparable(%Regex{} = value), do: Regex.source(value)
  def comparable(value), do: value
end
