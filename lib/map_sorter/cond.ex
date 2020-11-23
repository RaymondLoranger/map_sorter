defmodule MapSorter.Cond do
  @moduledoc """
  Generates cond clauses as a heredoc from a list of `sort specs`.
  """

  import MapSorter.Container, only: [brackets: 1]

  alias MapSorter.{SortSpec, SortSpecs}

  @doc """
  Generates cond clauses as a heredoc from a list of `sort specs`.

  ## Examples

      iex> alias MapSorter.Cond
      iex> sort_specs = [:name, {:desc, :dob}]
      iex> Cond.clauses(sort_specs)
      \"""
      &1[:name] < &2[:name] -> true
      &1[:name] > &2[:name] -> false
      &1[:dob] > &2[:dob] -> true
      &1[:dob] < &2[:dob] -> false
      \"""

      iex> alias MapSorter.Cond
      iex> sort_specs = [:name, {:desc, {:dob, Date}}]
      iex> Cond.clauses(sort_specs)
      \"""
      &1[:name] < &2[:name] -> true
      &1[:name] > &2[:name] -> false
      &1[:dob] != nil and Date.compare(&1[:dob], &2[:dob]) == :gt -> true
      &1[:dob] != nil and Date.compare(&1[:dob], &2[:dob]) == :lt -> false
      \"""
  """
  @spec clauses(SortSpecs.t()) :: String.t()
  def clauses(sort_specs) when is_list(sort_specs) do
    Enum.map_join(sort_specs, &do_clauses/1)
  end

  ## Private functions

  # Use short-circuit 'and' to prevent compare if key not in map...
  @spec cond(SortSpec.key(), String.t(), atom) :: String.t()
  defp cond(key, module, op) when op in [:lt, :gt] do
    """
    &1#{brackets(key)} != nil and\s
    #{module}.compare(&1#{brackets(key)}, &2#{brackets(key)}) == #{inspect(op)}
    """
    |> String.replace("\n", "")
  end

  @spec do_clauses(SortSpec.t()) :: String.t()
  defp do_clauses({:asc, {key, module}}) when is_atom(module) do
    with {:module, module} <- Code.ensure_loaded(module),
         true <- function_exported?(module, :compare, 2) do
      module = "#{inspect(module)}"

      """
      #{cond(key, module, :lt)} -> true
      #{cond(key, module, :gt)} -> false
      """
    else
      _no_module_or_function ->
        key = {key, module}

        """
        &1#{brackets(key)} < &2#{brackets(key)} -> true
        &1#{brackets(key)} > &2#{brackets(key)} -> false
        """
    end
  end

  defp do_clauses({:desc, {key, module}}) when is_atom(module) do
    with {:module, module} <- Code.ensure_loaded(module),
         true <- function_exported?(module, :compare, 2) do
      module = "#{inspect(module)}"

      """
      #{cond(key, module, :gt)} -> true
      #{cond(key, module, :lt)} -> false
      """
    else
      _no_module_or_function ->
        key = {key, module}

        """
        &1#{brackets(key)} > &2#{brackets(key)} -> true
        &1#{brackets(key)} < &2#{brackets(key)} -> false
        """
    end
  end

  defp do_clauses({:asc, key}) do
    """
    &1#{brackets(key)} < &2#{brackets(key)} -> true
    &1#{brackets(key)} > &2#{brackets(key)} -> false
    """
  end

  defp do_clauses({:desc, key}) do
    """
    &1#{brackets(key)} > &2#{brackets(key)} -> true
    &1#{brackets(key)} < &2#{brackets(key)} -> false
    """
  end

  defp do_clauses({key, module}) when is_atom(module) do
    do_clauses({:asc, {key, module}})
  end

  defp do_clauses(key) do
    do_clauses({:asc, key})
  end
end
