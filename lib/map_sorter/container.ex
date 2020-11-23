defmodule MapSorter.Container do
  @moduledoc """
  Generates index brackets as a string from a sort spec `key`.
  """

  alias MapSorter.SortSpec

  @doc """
  Generates index brackets as a string from a sort spec `key`.

  ## Examples

      iex> import MapSorter.Container, only: [brackets: 1]
      iex> brackets([:birth, :date])
      "[:birth][:date]"

      iex> import MapSorter.Container, only: [brackets: 1]
      iex> brackets([:address, 'city', :state])
      "[:address]['city'][:state]"

      iex> import MapSorter.Container, only: [brackets: 1]
      iex> brackets([:dob])
      "[:dob]"

      iex> import MapSorter.Container, only: [brackets: 1]
      iex> brackets(:dob)
      "[:dob]"

      iex> import MapSorter.Container, only: [brackets: 1]
      iex> brackets('dob')
      "['dob']"
  """
  @spec brackets(SortSpec.key()) :: String.t()
  def brackets([h | _t] = key) when is_integer(h) do
    # Assuming key is charlist...
    "[#{inspect(key)}]"
  end

  def brackets(key) when is_list(key) do
    Enum.map_join(key, &brackets/1)
  end

  def brackets(key) do
    "[#{inspect(key)}]"
  end
end
