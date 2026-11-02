defmodule MapSorter.SortSpec do
  @moduledoc """
  Defines sort spec types and generates square brackets access syntax strings.
  """

  # :dob | [:birth, :date] | ["name", "maiden"]
  @typedoc "Sort spec key"
  @type key :: Map.key() | [Map.key()]

  # Ascending or descending order...
  @typedoc "Sort direction"
  @type sort_dir :: :asc | :desc

  # :dob | {:dob, Date} | {:desc, :dob} | {:desc, {:dob, Date}}
  @typedoc "Sort spec"
  @type t :: key | {key, module} | {sort_dir, key} | {sort_dir, {key, module}}

  @doc """
  Generates a square brackets access syntax string from a sort spec `key`.

  ## Examples

      iex> import MapSorter.SortSpec
      iex> brackets([:birth, :date])
      "[:birth][:date]"

      iex> import MapSorter.SortSpec
      iex> brackets([:address, CITY, :state])
      "[:address][CITY][:state]"

      iex> import MapSorter.SortSpec
      iex> brackets([:dob])
      "[:dob]"

      iex> import MapSorter.SortSpec
      iex> brackets(:dob)
      "[:dob]"

      iex> import MapSorter.SortSpec
      iex> brackets(DOB)
      "[DOB]"

      iex> import MapSorter.SortSpec
      iex> brackets([1, <<1, 2, 3>>, 3.14, DOB])
      "[1][<<1, 2, 3>>][3.14][DOB]"

      iex> import MapSorter.SortSpec
      iex> brackets([DOB, "3.14", 3.14, 0, {1, 2}, :likes])
      ~s<[DOB]["3.14"][3.14][0][{1, 2}][:likes]>

      iex> import MapSorter.SortSpec
      iex> brackets([{[:birth, :date], Date}, :likes])
      "[{[:birth, :date], Date}][:likes]"

      iex> import MapSorter.SortSpec
      iex> brackets([{:desc, {[:birth, :date], Date}}, :likes])
      "[{:desc, {[:birth, :date], Date}}][:likes]"

      iex> import MapSorter.SortSpec
      iex> brackets(~c"abc")
      ~s<[~c"abc"]>
  """
  @spec brackets(key) :: String.t()
  def brackets(key) when is_list(key) do
    if List.ascii_printable?(key) do
      # A printable charlist...
      "[#{inspect(key)}]"
    else
      # A list of sort keys...
      Enum.map_join(key, &brackets/1)
    end
  end

  def brackets(key) do
    "[#{inspect(key)}]"
  end
end
