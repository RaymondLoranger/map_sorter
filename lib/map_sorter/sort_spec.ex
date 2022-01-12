defmodule MapSorter.SortSpec do
  @moduledoc """
  Defines the sort spec types.
  """

  # :dob | [:birth, :date]
  @typedoc "Sort spec key"
  @type key :: Map.key() | [Map.key()]

  # Ascending or descending order...
  @typedoc "Sort direction"
  @type sort_dir :: :asc | :desc

  # :dob | {:dob, Date} | {:desc, :dob} | {:desc, {:dob, Date}}
  @typedoc "Sort spec"
  @type t :: key | {key, module} | {sort_dir, key} | {sort_dir, {key, module}}
end
