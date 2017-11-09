defmodule MapSorter do
  @moduledoc """
  Sorts a list of `maps` as per a list of `sort specs`
  (ascending/descending keys).

  Also works for keywords or structures implementing the Access behaviour.
  """

  require Logger

  @doc """
  Sorts `maps` as per its `sort specs` (compile time or runtime).

  `sort specs` can be implicit, explicit or mixed:

  - [:dob, :name]            - _implicit_ ≡ [_asc:_ :dob, _asc:_ :name]
  - [:dob, desc: :name]      - _mixed_    ≡ [_asc:_ :dob, desc: :name]
  - [asc: :dob, desc: :name] - _explicit_

  ## Examples

      iex> require MapSorter
      iex> people = [
      ...>   %{name: "Mike", likes: "movies" , dob: ~D[1992-04-15]},
      ...>   %{name: "Mary", likes: "travels", dob: ~D[1992-04-15]},
      ...>   %{name: "Ann" , likes: "reading", dob: ~D[1992-04-15]},
      ...>   %{name: "Ray" , likes: "cycling", dob: ~D[1977-08-28]},
      ...>   %{name: "Bill", likes: "karate" , dob: ~D[1977-08-28]},
      ...>   %{name: "Joe" , likes: "boxing" , dob: ~D[1977-08-28]},
      ...>   %{name: "Jill", likes: "cooking", dob: ~D[1976-09-28]}
      ...> ]
      iex> fun = & &1
      iex> MapSorter.log_level(:info) # :debug → debug messages
      iex> sorted = %{
      ...>   explicit: MapSorter.sort(people, asc: :dob, desc: :likes),
      ...>   mixed:    MapSorter.sort(people, [:dob, desc: :likes]),
      ...>   runtime:  MapSorter.sort(people, fun.([:dob, desc: :likes]))
      ...> }
      iex> MapSorter.log_level(:info)
      iex> sorted.explicit == sorted.mixed and
      ...> sorted.explicit == sorted.runtime and
      ...> sorted.explicit
      [
        %{name: "Jill", likes: "cooking", dob: ~D[1976-09-28]},
        %{name: "Bill", likes: "karate" , dob: ~D[1977-08-28]},
        %{name: "Ray" , likes: "cycling", dob: ~D[1977-08-28]},
        %{name: "Joe" , likes: "boxing" , dob: ~D[1977-08-28]},
        %{name: "Mary", likes: "travels", dob: ~D[1992-04-15]},
        %{name: "Ann" , likes: "reading", dob: ~D[1992-04-15]},
        %{name: "Mike", likes: "movies" , dob: ~D[1992-04-15]}
      ]
  """
  defmacro sort(maps, sort_specs) do
    Logger.debug("sort specs: #{inspect(sort_specs)}...")
    sort_fun =
      case sort_specs do
        specs when is_list(specs) -> specs
        specs -> Macro.expand(specs, __CALLER__) # in case module attribute
      end
      |> MapSorter.Impl.sort_fun()
    quote do: Enum.sort(unquote(maps), unquote(sort_fun))
  end

  @doc """
  Allows to change the log `level` at compile time.
  """
  defmacro log_level(level), do: Logger.configure(level: level)
end
