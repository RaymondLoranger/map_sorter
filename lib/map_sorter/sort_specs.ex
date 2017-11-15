defmodule MapSorter.SortSpecs do
  @app Mix.Project.config[:app]
  @url Application.get_env(@app, :compare_function_url)

  @moduledoc """
  Generates a [compare function](#{@url}) from a list of `sort specs`
  (ascending/descending keys).
  """

  @moduledoc false

  require Logger

  @type comp_fun :: (Access.container, Access.container -> boolean)
  @type sort_dir :: :asc | :desc
  @type sort_spec :: any | {sort_dir, any}

  @structs_enabled? Application.get_env(@app, :structs_enabled?)
  @prefix @structs_enabled? && "#{__MODULE__}.comparable(" || ""
  @suffix @structs_enabled? && ")" || ""

  @doc """
  Converts `sort specs` to the AST of a [compare function](#{@url})
  (compile time or runtime).

  ## Examples

      iex> alias MapSorter.SortSpecs
      iex> sort_specs = [:dob, desc: :likes]
      iex> {:ok, comp_fun_ast} = SortSpecs.to_quoted(sort_specs)
      iex> match?({:&, _meta, _args}, comp_fun_ast) and
      iex> match?([_, _], sort_specs)
      true

      iex> alias MapSorter.SortSpecs
      iex> sort_specs = quote do: Tuple.to_list({:dob, {:desc, :likes}})
      iex> {:ok, comp_fun_ast} = SortSpecs.to_quoted(sort_specs)
      iex> match?({{:., _, _}, _meta, _args}, comp_fun_ast) and
      iex> match?({{:., _, _}, _meta, _args}, sort_specs)
      true
  """
  @spec to_quoted([sort_spec] | Macro.expr) :: {:ok, Macro.expr} | {:error, any}
  def to_quoted(sort_specs) when is_list(sort_specs) do
    Logger.debug("expanding: to_quoted(#{inspect(sort_specs)})...")
    sort_specs |> fun_string() |> Code.string_to_quoted()
  end
  def to_quoted({:%{}, _, _} = sort_specs), do: {:error, sort_specs}
  def to_quoted({:{}, _, _} = sort_specs), do: {:error, sort_specs}
  def to_quoted({_, meta, _} = sort_specs) do
    if Keyword.keyword?(meta) do
      Logger.debug("injecting: to_comp_fun(#{inspect(sort_specs)})...")
      quote do: {:ok, MapSorter.SortSpecs.to_comp_fun(unquote(sort_specs))}
    else
      {:error, sort_specs}
    end
  end
  def to_quoted(sort_specs), do: {:error, sort_specs}

  @doc """
  Converts `sort specs` to a [compare function](#{@url}).

  ## Examples

      iex> alias MapSorter.SortSpecs
      iex> comp_fun = SortSpecs.to_comp_fun([:dob, desc: :likes])
      iex> is_function(comp_fun, 2)
      true
  """
  @spec to_comp_fun([sort_spec]) :: comp_fun
  def to_comp_fun(sort_specs) when is_list(sort_specs) do
    Logger.debug("running: to_comp_fun(#{inspect(sort_specs)})...")
    {comp_fun, []} = sort_specs |> fun_string() |> Code.eval_string()
    comp_fun
  end
  def to_comp_fun(_sort_specs), do: to_comp_fun([])

  @spec fun_string([sort_spec]) :: String.t
  defp fun_string(sort_specs) do
    fun_string =
      sort_specs
      |> Enum.map_join(&clauses_doc/1)
      |> fun_doc()
    Logger.debug(fun_string)
    fun_string
  end

  @spec fun_doc(String.t) :: String.t
  defp fun_doc(clauses) do
    """
    & cond do
    #{clauses}true -> true or &1 * &2
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

      iex> alias MapSorter.SortSpecs
      iex> doc =
      ...>   \"""
      ...>   &1[:dob] < ...
      ...>   &2[:likes] -> ...
      ...>   \"""
      iex> SortSpecs.adapt_string(doc, true)
      \"""
      Elixir.MapSorter.SortSpecs.comparable(&1[:dob]) < ...
      Elixir.MapSorter.SortSpecs.comparable(&2[:likes]) -> ...
      \"""

      iex> alias MapSorter.SortSpecs
      iex> doc =
      ...>   \"""
      ...>   &1[:dob] < ...
      ...>   &2[:likes] -> ...
      ...>   \"""
      iex> SortSpecs.adapt_string(doc, false)
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

  @url Application.get_env(@app, :comparable_protocol_url)

  @doc """
  Converts a `value` to a [comparable](#{@url}) format, if needed.

  ## Examples

      iex> alias MapSorter.SortSpecs
      iex> SortSpecs.comparable(~T[15:41:33])
      "15:41:33"

      iex> alias MapSorter.SortSpecs
      iex> SortSpecs.comparable(3.1416)
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
