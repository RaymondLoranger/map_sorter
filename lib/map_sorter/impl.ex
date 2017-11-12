defmodule MapSorter.Impl do
  @moduledoc """
  Generates a sort function from a list of `sort specs`
  (ascending/descending keys).
  """

  require Logger

  @type sort_dir :: :asc | :desc
  @type sort_fun :: (map, map -> boolean)
  @type sort_spec :: any | {sort_dir, any}

  @app Mix.Project.config[:app]
  @structs_enabled? Application.get_env(@app, :structs_enabled?)
  @prefix @structs_enabled? && "#{__MODULE__}.comparable(" || ""
  @suffix @structs_enabled? && ")" || ""
  @url Application.get_env(@app, :comparable_protocol_url)

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
      |> fun_string()
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
      |> fun_string()
      |> Code.eval_string()
    sort_fun
  end

  @spec fun_string([sort_spec]) :: String.t
  defp fun_string(sort_specs) do
    fun_string =
      sort_specs
      |> Enum.map_join(&clauses_doc/1)
      |> String.trim_trailing()
      |> fun_doc()
    Logger.debug(fun_string)
    fun_string
  end

  @spec fun_doc(String.t) :: String.t
  defp fun_doc(clauses) do
    """
    & cond do
    #{clauses}
    true -> true
    end
    """
  end

  @spec clauses_doc(sort_spec) :: String.t
  defp clauses_doc({:asc, key}) do
    """
    #{comparand(1, key)} < #{comparand(2, key)} -> true
    #{comparand(1, key)} > #{comparand(2, key)} -> false
    """
  end
  defp clauses_doc({:desc, key}) do
    """
    #{comparand(1, key)} > #{comparand(2, key)} -> true
    #{comparand(1, key)} < #{comparand(2, key)} -> false
    """
  end
  defp clauses_doc(key), do: clauses_doc({:asc, key})

  @spec comparand(non_neg_integer, any) :: String.t
  defp comparand(rank, key) do
    "#{@prefix}&#{rank}#{brackets(key)}#{@suffix}"
  end

  defp brackets(key) when is_list(key) do
    Enum.map_join(key, &"[#{inspect(&1)}]")
  end
  defp brackets(key) do
    "[#{inspect(key)}]"
  end

  @doc """
  Adapts `string` to `maybe` invoke the `comparable/1` function.

  ## Examples

      iex> alias MapSorter.Impl
      iex> doc =
      ...>   \"""
      ...>   &1[:dob] < ...
      ...>   &2[:likes] -> ...
      ...>   \"""
      iex> Impl.adapt_string(doc, true)
      \"""
      Elixir.MapSorter.Impl.comparable(&1[:dob]) < ...
      Elixir.MapSorter.Impl.comparable(&2[:likes]) -> ...
      \"""

      iex> alias MapSorter.Impl
      iex> doc =
      ...>   \"""
      ...>   &1[:dob] < ...
      ...>   &2[:likes] -> ...
      ...>   \"""
      iex> Impl.adapt_string(doc, false)
      \"""
      &1[:dob] < ...
      &2[:likes] -> ...
      \"""
  """
  @spec adapt_string(String.t, boolean) :: String.t
  def adapt_string(string, maybe) do
    # &1[:branch][:dept] < &2[:branch][:dept] -> true
    regex = ~r/(&[12]\[.+?])( +[<>-])/
    replacement = "#{prefix(maybe)}\\1#{suffix(maybe)}\\2"
    String.replace(string, regex, replacement)
  end

  @spec prefix(boolean) :: String.t
  defp prefix(maybe), do: maybe && "#{__MODULE__}.comparable(" || ""

  @spec suffix(boolean) :: String.t
  defp suffix(maybe), do: maybe && ")" || ""

  @doc """
  Converts a `value` to a [comparable](#{@url}) format, if needed.

  ## Examples

      iex> alias MapSorter.Impl
      iex> Impl.comparable(~T[15:41:33])
      "15:41:33"

      iex> alias MapSorter.Impl
      iex> Impl.comparable(3.1416)
      3.1416
  """
  @spec comparable(any) :: any
  def comparable(%Date{}          = value), do: Date.to_string(value)
  def comparable(%DateTime{}      = value), do: DateTime.to_string(value)
  def comparable(%NaiveDateTime{} = value), do: NaiveDateTime.to_string(value)
  def comparable(%Time{}          = value), do: Time.to_string(value)
  def comparable(%Version{}       = value), do: to_string(value)
  def comparable(%Regex{}         = value), do: Regex.source(value)
  def comparable(value            = value), do: value
end
