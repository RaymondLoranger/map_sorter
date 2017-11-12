# Map Sorter

Sorts a list of `maps` as per a list of `sort specs`
(ascending/descending keys).

Also supports:

- keywords
- structs implementing the Access behaviour
- nested maps, keywords or structs implementing the Access behaviour

## Installation

Add the `:map_sorter` dependency to your `mix.exs` file:

```elixir
def deps() do
  [
    {:map_sorter, "~> 0.1"}
  ]
end
```

## Usage

```elixir
require MapSorter
MapSorter.sort(maps, sort_specs)
```

Sorts `maps` as per its `sort specs` (compile time or runtime).

`sort specs` can be implicit, explicit or mixed:
  - implicit: [:dob, :name]
  - mixed:    [:dob, desc: :name]
  - explicit: [asc: :dob, desc: :name]

`sort specs` for nested data structures:
  - implicit: [[:birth, :date], [:name, :first]]
  - mixed:    [[:birth, :date], desc: [:name, :first]]
  - explicit: [asc: [:birth, :date], desc: [:name, :first]]

## Note

To allow sorting on structs like `%DateTime{}` or `%Time{}`,
you should add the following to your `config.exs` file:

```elixir
config :map_sorter, structs_enabled?: true
```

And then you should recompile the `:map_sorter` dependency:

```
mix deps.compile map_sorter
```

## Examples

```elixir
require MapSorter
people = [
  %{name: "Mike", likes: "ski, arts", dob: "1992-04-15"},
  %{name: "Mary", likes: "travels"  , dob: "1992-04-15"},
  %{name: "Ann" , likes: "reading"  , dob: "1992-04-15"},
  %{name: "Ray" , likes: "cycling"  , dob: "1977-08-28"},
  %{name: "Bill", likes: "karate"   , dob: "1977-08-28"},
  %{name: "Joe" , likes: "boxing"   , dob: "1977-08-28"},
  %{name: "Jill", likes: "cooking"  , dob: "1976-09-28"}
]
MapSorter.sort(people, asc: :dob, desc: :likes)
```

The above code will sort `people` ascendingly by `:dob` and
descendingly by `:likes` as follows:

```elixir
[
  %{name: "Jill", likes: "cooking"  , dob: "1976-09-28"},
  %{name: "Bill", likes: "karate"   , dob: "1977-08-28"},
  %{name: "Ray" , likes: "cycling"  , dob: "1977-08-28"},
  %{name: "Joe" , likes: "boxing"   , dob: "1977-08-28"},
  %{name: "Mary", likes: "travels"  , dob: "1992-04-15"},
  %{name: "Mike", likes: "ski, arts", dob: "1992-04-15"},
  %{name: "Ann" , likes: "reading"  , dob: "1992-04-15"}
]
```



```elixir
require MapSorter
people = [
  %{name: [first: "Meg", last: "Hill"], birth: [date: ~D[1977-01-23]]},
  %{name: [first: "Meg", last: "Howe"], birth: [date: ~D[1966-01-23]]},
  %{name: [first: "Joe", last: "Holt"], birth: [date: ~D[1988-01-23]]},
  %{name: [first: "Meg", last: "Hunt"], birth: [date: ~D[1955-01-23]]}
]
MapSorter.sort(people, asc: [:name, :first], desc: [:birth, :date])
```

The above code will sort `people` ascendingly by `first name` and
descendingly by `birth date` as follows (see note above):

```elixir
[
  %{name: [first: "Joe", last: "Holt"], birth: [date: ~D[1988-01-23]]},
  %{name: [first: "Meg", last: "Hill"], birth: [date: ~D[1977-01-23]]},
  %{name: [first: "Meg", last: "Howe"], birth: [date: ~D[1966-01-23]]},
  %{name: [first: "Meg", last: "Hunt"], birth: [date: ~D[1955-01-23]]}
]
```
