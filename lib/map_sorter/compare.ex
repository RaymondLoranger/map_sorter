defmodule MapSorter.Compare do
  use PersistConfig

  @compare_function get_env(:compare_function)

  @moduledoc """
  Generates a #{@compare_function} from a list of `sort specs`.
  """

  alias MapSorter.{Cond, Log, SortSpecs}

  # Access.container() :: keyword() | struct() | map()
  @type fun :: (Access.container(), Access.container() -> boolean)

  @doc """
  Generates a #{@compare_function} from a list of `sort specs`.

  ## Examples

      iex> alias MapSorter.Compare
      iex> sort_specs = [:dob, desc: :likes]
      iex> fun = Compare.fun(sort_specs)
      iex> is_function(fun, 2)
      true
  """
  @spec fun(SortSpecs.t()) :: fun
  def fun(sort_specs) when is_list(sort_specs) do
    Log.debug(:generating_runtime_comp_fun, {sort_specs, __ENV__})
    {fun, []} = heredoc(sort_specs) |> Code.eval_string()
    fun
  end

  def fun(sort_specs) do
    Log.error(:generating_no_op_sort, {sort_specs, __ENV__})
    fun([])
  end

  @doc """
  Generates a #{@compare_function} as a heredoc from a list of `sort specs`.

  ## Examples

      iex> alias MapSorter.Compare
      iex> Compare.heredoc([])
      \"""
      & cond do
      true -> true or &1 * &2
      end
      \"""

      iex> alias MapSorter.Compare
      iex> sort_specs = [:name, {:desc, :dob}]
      iex> Compare.heredoc(sort_specs)
      \"""
      & cond do
      &1[:name] < &2[:name] -> true
      &1[:name] > &2[:name] -> false
      &1[:dob] > &2[:dob] -> true
      &1[:dob] < &2[:dob] -> false
      true -> true or &1 * &2
      end
      \"""

      iex> alias MapSorter.Compare
      iex> sort_specs = [:name, {:desc, {:dob, Date}}]
      iex> Compare.heredoc(sort_specs)
      \"""
      & cond do
      &1[:name] < &2[:name] -> true
      &1[:name] > &2[:name] -> false
      &1[:dob] != nil and Date.compare(&1[:dob], &2[:dob]) == :gt -> true
      &1[:dob] != nil and Date.compare(&1[:dob], &2[:dob]) == :lt -> false
      true -> true or &1 * &2
      end
      \"""
  """
  @spec heredoc(SortSpecs.t()) :: String.t()
  def heredoc(sort_specs) when is_list(sort_specs) do
    heredoc = """
    & cond do
    #{Cond.clauses(sort_specs)}true -> true or &1 * &2
    end
    """

    Log.debug(:comp_fun_heredoc, {sort_specs, heredoc, __ENV__})
    heredoc
  end
end
