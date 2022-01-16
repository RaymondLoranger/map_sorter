defmodule MapSorter.Compare do
  @moduledoc """
  A compare function and a heredoc to become a compare function.
  """

  alias MapSorter.{Cond, Log, SortSpecs}

  # Cannot use type `fun` as it is a built-in type...
  # Access.container() :: keyword() | struct() | map()
  @typedoc "Compare function"
  @type comp_fun :: (Access.container(), Access.container() -> boolean)

  @doc """
  Generates an `Enum.sort/2` compare function from a list of sort specs.

  ## Examples

      iex> alias MapSorter.Compare
      iex> sort_specs = [:dob, desc: :likes]
      iex> fun = Compare.fun(sort_specs)
      iex> is_function(fun, 2)
      true

      iex> alias MapSorter.Compare
      iex> sort_specs = fn -> [:dob, desc: :likes] end
      iex> fun = Compare.fun(sort_specs.())
      iex> is_function(fun, 2)
      true

      iex> alias MapSorter.Compare
      iex> sort_specs = Tuple.to_list({:dob, {:desc, :likes}})
      iex> fun = Compare.fun(sort_specs)
      iex> is_function(fun, 2)
      true
  """
  @spec fun(SortSpecs.t()) :: comp_fun
  def fun(sort_specs) when is_list(sort_specs) do
    :ok = Log.debug(:generating_runtime_heredoc, {sort_specs, __ENV__})
    {fun, []} = heredoc(sort_specs) |> Code.eval_string()
    fun
  end

  def fun(sort_specs) do
    :ok = Log.warn(:generating_no_op_sort, {sort_specs, __ENV__})
    fun([])
  end

  @doc ~S'''
  Generates a `cond/1` expression as a heredoc to become a compare function.

  The heredoc may be converted into its quoted form at compile time or else
  have its contents evaluated at runtime.

  This function cannot be named `cond` as it is among the `Kernel.SpecialForms`.

  ## Examples

      iex> alias MapSorter.Compare
      iex> Compare.heredoc([])
      """
      & cond do
      true -> true or &1 * &2
      end
      """

      iex> alias MapSorter.Compare
      iex> sort_specs = [:name, {:desc, :dob}]
      iex> Compare.heredoc(sort_specs)
      """
      & cond do
      &1[:name] < &2[:name] -> true
      &1[:name] > &2[:name] -> false
      &1[:dob] > &2[:dob] -> true
      &1[:dob] < &2[:dob] -> false
      true -> true or &1 * &2
      end
      """

      iex> alias MapSorter.Compare
      iex> sort_specs = [:name, {:desc, {:dob, Date}}]
      iex> Compare.heredoc(sort_specs)
      """
      & cond do
      &1[:name] < &2[:name] -> true
      &1[:name] > &2[:name] -> false
      &1[:dob] != nil and Date.compare(&1[:dob], &2[:dob]) == :gt -> true
      &1[:dob] != nil and Date.compare(&1[:dob], &2[:dob]) == :lt -> false
      true -> true or &1 * &2
      end
      """

      iex> alias MapSorter.Compare
      iex> sort_specs = [:name, {:desc, {:account, Path}}]
      iex> Compare.heredoc(sort_specs)
      """
      & cond do
      &1[:name] < &2[:name] -> true
      &1[:name] > &2[:name] -> false
      &1[{:account, Path}] > &2[{:account, Path}] -> true
      &1[{:account, Path}] < &2[{:account, Path}] -> false
      true -> true or &1 * &2
      end
      """
  '''
  @spec heredoc(SortSpecs.t()) :: String.t()
  def heredoc(sort_specs) when is_list(sort_specs) do
    heredoc = """
    & cond do
    #{Cond.clauses(sort_specs)}true -> true or &1 * &2
    end
    """

    :ok = Log.debug(:comp_fun_heredoc, {sort_specs, heredoc, __ENV__})
    heredoc
  end
end
