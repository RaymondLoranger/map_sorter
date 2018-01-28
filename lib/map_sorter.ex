defmodule MapSorter do
  @moduledoc """
  Sorts a list of `maps` as per a list of `sort specs`
  (ascending/descending keys).

  Also supports:
  - keywords
  - structs implementing the Access behaviour
  - nested maps, keywords or structs implementing the Access behaviour
  """

  alias __MODULE__.SortSpec

  require Logger

  @doc """
  Sorts `maps` as per the given `sort specs` (compile time or runtime).

  Examples of `sort specs` for flat data structures:
  - implicit: [:dob, :name]       ≡ [_asc:_ :dob, _asc:_ :name]
  - mixed:    [:dob, desc: :name] ≡ [_asc:_ :dob, desc: :name]
  - explicit: [asc: :dob, desc: :name]

  Examples of `sort specs` for nested data structures:
  - implicit: [[:birth, :date], :name]
  - mixed:    [[:birth, :date], desc: :name]
  - explicit: [asc: [:birth, :date], desc: :name]

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
      iex> sorted_people = %{
      ...>   explicit: MapSorter.sort(people, asc: :dob, desc: :likes),
      ...>   mixed:    MapSorter.sort(people, [:dob, desc: :likes]),
      ...>   runtime:  MapSorter.sort(people, sort_specs)
      ...> }
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
  """
  defmacro sort(maps, sort_specs) do
    Logger.debug("sort specs: #{inspect(sort_specs)}...")

    specs =
      case sort_specs do
        specs when is_list(specs) ->
          specs

        # In case any module attribute(s)...
        specs ->
          Macro.expand(specs, __CALLER__)
      end

    case SortSpec.to_quoted(specs) do
      {:ok, comp_fun} ->
        quote do: Enum.sort(unquote(maps), unquote(comp_fun))

      {:error, bad_specs} ->
        Logger.warn("bad sort specs: #{inspect(bad_specs)}")
        maps
    end
  end

  # @doc """
  # Allows to change the log `level` at compile time.
  # """
  @doc false
  defmacro log_level(level), do: Logger.configure(level: level)
end
