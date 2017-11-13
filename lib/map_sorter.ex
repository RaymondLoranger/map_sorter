defmodule MapSorter do
  @moduledoc """
  Sorts a list of `maps` as per a list of `sort specs`
  (ascending/descending keys).

  Also supports:

  - keywords
  - structs implementing the Access behaviour
  - nested maps, keywords or structs implementing the Access behaviour
  """

  alias MapSorter.SortSpecs

  require Logger

  @doc """
  Sorts `maps` as per its `sort specs` (compile time or runtime).

  `sort specs` can be implicit, explicit or mixed:
    - implicit: [:dob, :name]       ≡ [asc: :dob, asc: :name]
    - mixed:    [:dob, desc: :name] ≡ [asc: :dob, desc: :name]
    - explicit: [asc: :dob, desc: :name]

  `sort specs` for nested data structures:
    - implicit: [[:birth, :date], [:name, :first]]
    - mixed:    [[:birth, :date], desc: [:name, :first]]
    - explicit: [asc: [:birth, :date], desc: [:name, :first]]

  ## Examples

      iex> require MapSorter
      iex> people = [
      ...>   %{name: "Mike", likes: "movies" , dob: "1992-04-15"},
      ...>   %{name: "Mary", likes: "travels", dob: "1992-04-15"},
      ...>   %{name: "Bill", likes: "karate" , dob: "1977-08-28"},
      ...>   %{name: "Joe" , likes: "boxing" , dob: "1977-08-28"},
      ...>   %{name: "Jill", likes: "cooking", dob: "1976-09-28"}
      ...> ]
      iex> sort_specs = [:dob, desc: :likes]
      iex> MapSorter.log_level(:info) # :debug → debug messages
      iex> sorted_people = %{
      ...>   explicit: MapSorter.sort(people, asc: :dob, desc: :likes),
      ...>   mixed:    MapSorter.sort(people, [:dob, desc: :likes]),
      ...>   runtime:  MapSorter.sort(people, sort_specs)
      ...> }
      iex> MapSorter.log_level(:info)
      iex> sorted_people.explicit == sorted_people.mixed and
      ...> sorted_people.explicit == sorted_people.runtime and
      ...> sorted_people.explicit
      [
        %{name: "Jill", likes: "cooking", dob: "1976-09-28"},
        %{name: "Bill", likes: "karate" , dob: "1977-08-28"},
        %{name: "Joe" , likes: "boxing" , dob: "1977-08-28"},
        %{name: "Mary", likes: "travels", dob: "1992-04-15"},
        %{name: "Mike", likes: "movies" , dob: "1992-04-15"}
      ]

      iex> require MapSorter
      iex> people = [
      ...>   %{name: "Mike", likes: "movies" , dob: "1992-04-15"},
      ...>   %{name: "Mary", likes: "travels", dob: "1992-04-15"},
      ...>   %{name: "Bill", likes: "karate" , dob: "1977-08-28"},
      ...>   %{name: "Joe" , likes: "boxing" , dob: "1977-08-28"},
      ...>   %{name: "Jill", likes: "cooking", dob: "1976-09-28"}
      ...> ]
      iex> bad_specs = %{asc: :dob, desc: :likes}
      iex> MapSorter.log_level(:info) # :debug → debug messages
      iex> sorted_people = %{
      ...>   bad_literal: MapSorter.sort(people, %{asc: :dob, desc: :likes}),
      ...>   bad_runtime: MapSorter.sort(people, bad_specs),
      ...>   empty_specs: MapSorter.sort(people, []),
      ...>   nihil_specs: MapSorter.sort(people, nil)
      ...> }
      iex> MapSorter.log_level(:info)
      iex> sorted_people.bad_literal == people and
      ...> sorted_people.bad_runtime == people
      ...> sorted_people.empty_specs == people
      ...> sorted_people.nihil_specs == people
      true
  """
  defmacro sort(maps, sort_specs) do
    Logger.debug("sort specs: #{inspect(sort_specs)}...")
    specs =
      case sort_specs do
        specs when is_list(specs) -> specs
        specs -> Macro.expand(specs, __CALLER__) # in case module attribute
      end
    case SortSpecs.to_quoted(specs) do
      {:ok, fun} -> quote do: Enum.sort(unquote(maps), unquote(fun))
      {:error, bad_specs} ->
        Logger.debug("bad sort specs: #{inspect(bad_specs)}")
        maps
    end
  end

  @doc """
  Allows to change the log `level` at compile time.
  """
  defmacro log_level(level), do: Logger.configure(level: level)
end
