defmodule MapSorter.SortSpec do
  @moduledoc """
  Defines the `sort spec` types.
  """

  # :dob | [:birth, :date]
  @type key :: term | [term]

  # For ascending or descending order...
  @type sort_dir :: :asc | :desc

  # :dob | {:dob, Date} | {:desc, :dob} | {:desc, {:dob, Date}}
  @type t :: key | {key, module} | {sort_dir, key} | {sort_dir, {key, module}}
end
