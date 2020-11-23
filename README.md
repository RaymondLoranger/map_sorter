# Map Sorter

[![Build Status](https://travis-ci.org/RaymondLoranger/map_sorter.svg?branch=master)](https://travis-ci.org/RaymondLoranger/map_sorter)

Sorts a list of `maps` per a list of `sort specs`.

Also supports:

- keywords
- structs implementing the Access behaviour
- nested maps, keywords or structs implementing the Access behaviour

## Installation

Add `map_sorter` to your list of dependencies in `mix.exs`:

```elixir
def deps() do
  [
    {:map_sorter, "~> 0.2"}
  ]
end
```

## Usage

```elixir
require MapSorter
MapSorter.sort(maps, sort_specs)
```

Examples of `sort specs` for flat data structures:
```
- implicit: [:dob, :name]
- mixed:    [:dob, desc: :name]
- explicit: [asc: :dob, desc: :name]
```

Examples of `sort specs` with a `Date` key for flat data structures:
```
- implicit: [{:dob Date}, :name]
- mixed:    [{:dob Date}, desc: :name]
- explicit: [asc: {:dob Date}, desc: :name]
```

Examples of `sort specs` for nested data structures:
```
- implicit: [[:birth, :date], :name]
- mixed:    [[:birth, :date], desc: :name]
- explicit: [asc: [:birth, :date], desc: :name]
```

Examples of `sort specs` with a `Date` key for nested data structures:
```
- implicit: [{[:birth, :date], Date}, :name]
- mixed:    [{[:birth, :date], Date}, desc: :name]
- explicit: [asc: {[:birth, :date], Date}, desc: :name]
```

#### Example 1

```elixir
require MapSorter
people = [
  %{name: "Mike", likes: "ski, arts", dob: "1992-04-15"},
  %{name: "Mary", likes: "travels"  , dob: "1992-04-15"},
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
  %{name: "Joe" , likes: "boxing"   , dob: "1977-08-28"},
  %{name: "Mary", likes: "travels"  , dob: "1992-04-15"},
  %{name: "Mike", likes: "ski, arts", dob: "1992-04-15"}
]
```

#### Example 2

```elixir
require MapSorter
people = [
  %{name: "Mike", likes: "ski, arts", dob: ~D[1992-04-15]},
  %{name: "Mary", likes: "travels"  , dob: ~D[1992-04-15]},
  %{name: "Bill", likes: "karate"   , dob: ~D[1977-08-28]},
  %{name: "Joe" , likes: "boxing"   , dob: ~D[1977-08-28]},
  %{name: "Jill", likes: "cooking"  , dob: ~D[1976-09-28]}
]
MapSorter.sort(people, asc: {:dob, Date}, desc: :likes)
```

The above code will sort `people` ascendingly by `:dob` and
descendingly by `:likes` as follows:

```elixir
[
  %{name: "Jill", likes: "cooking"  , dob: ~D[1976-09-28]},
  %{name: "Bill", likes: "karate"   , dob: ~D[1977-08-28]},
  %{name: "Joe" , likes: "boxing"   , dob: ~D[1977-08-28]},
  %{name: "Mary", likes: "travels"  , dob: ~D[1992-04-15]},
  %{name: "Mike", likes: "ski, arts", dob: ~D[1992-04-15]}
]
```

#### Example 3

```elixir
require MapSorter
people = [
  %{name: [first: "Meg", last: "Hill"], birth: [date: ~D[1977-01-23]]},
  %{name: [first: "Meg", last: "Howe"], birth: [date: ~N[1977-01-23 01:02:03]]},
  %{name: [first: "Joe", last: "Holt"], birth: [date: ~N[1988-01-23 23:59:59]]},
  %{name: [first: "Meg", last: "Hunt"], birth: [date: ~D[1988-01-23]]}
]
MapSorter.sort(people, desc: {[:birth, :date], Date}, asc: [:name, :last])
```

The above code will sort `people` descendingly by `birth date` and
ascendingly by `last name` as follows:

```elixir
[
  %{name: [first: "Joe", last: "Holt"], birth: [date: ~N[1988-01-23 23:59:59]]},
  %{name: [first: "Meg", last: "Hunt"], birth: [date: ~D[1988-01-23]]},
  %{name: [first: "Meg", last: "Hill"], birth: [date: ~D[1977-01-23]]},
  %{name: [first: "Meg", last: "Howe"], birth: [date: ~N[1977-01-23 01:02:03]]}
]
```
