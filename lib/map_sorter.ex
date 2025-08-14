defmodule MapSorter do
  @moduledoc """
  Sorts a list of maps per a list of sort specs.

  Also supports:

  - keywords
  - structs implementing the `Access` behaviour
  - nested maps, keywords or structs implementing the `Access` behaviour
  """

  use PersistConfig

  alias __MODULE__.{Log, SortSpecs}

  @doc """
  Sorts `maps` per the given `sort_specs`.

  Examples of sort specs for flat data structures:
  ```
  - implicit: [:dob, :name]
  - mixed:    [:dob, desc: :name]
  - explicit: [asc: :dob, desc: :name]
  ```

  Examples of sort specs with a `Date` key for flat data structures:
  ```
  - implicit: [{:dob, Date}, :name]
  - mixed:    [{:dob, Date}, desc: :name]
  - explicit: [asc: {:dob, Date}, desc: :name]
  ```

  Examples of sort specs for nested data structures:
  ```
  - implicit: [[:birth, :date], :name]
  - mixed   : [[:birth, :date], desc: :name]
  - explicit: [asc: [:birth, :date], desc: :name]
  ```

  Examples of sort specs with a `Date` key for nested data structures:
  ```
  - implicit: [{[:birth, :date], Date}, :name]
  - mixed:    [{[:birth, :date], Date}, desc: :name]
  - explicit: [asc: {[:birth, :date], Date}, desc: :name]
  ```

  ## Examples

      iex> require MapSorter
      iex> people = [
      ...>   %{name: "Mike", likes: "movies" , dob: "1992-04-15"},
      ...>   %{name: "Mary", likes: "travels", dob: "1992-04-15"},
      ...>   %{name: "Bill", likes: "karate" , dob: "1977-08-28"},
      ...>   %{name: "Joe" , likes: "boxing" , dob: "1977-08-28"},
      ...>   %{name: "Jill", likes: "cooking", dob: "1976-09-28"}
      ...> ]
      iex> sort_specs = Tuple.to_list({:dob, {:desc, :likes}})
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
    specs =
      case sort_specs do
        specs when is_list(specs) ->
          # [asc: {:dob, {:__aliases__, [line: 7], [:Date]}}] =>
          # [asc: {:dob, Date}]
          {specs, []} = Code.eval_quoted(specs)
          specs

        specs ->
          # In case any module attributes...
          Macro.expand(specs, __CALLER__)
      end

    Log.debug(:sort_specs, {sort_specs, specs, __ENV__, __CALLER__})

    case SortSpecs.to_quoted(specs) do
      {:ok, fun_ast} ->
        quote do: Enum.sort(unquote(maps), unquote(fun_ast))

      {:error, invalid_specs} ->
        Log.warning(:invalid_specs, {invalid_specs, __ENV__, __CALLER__})
        maps
    end
  end
end
