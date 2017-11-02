# Map Sorter

Sorts a list of `maps` as per a list of sort specs
(ascending/descending keys).

Also works for keywords or structures implementing the Access behaviour.

## Installation

The package can be installed by adding `:map_sorter` to your list of
dependencies in `mix.exs`:

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

Sorts the `maps` as per the `sort specs` (compile time or runtime).

  `sort specs` can be implicit, explicit or mixed:

  - [:dob, :name]            - _implicit_ ≡ [_asc:_ :dob, _asc:_ :name]
  - [:dob, desc: :name]      - _mixed_    ≡ [_asc:_ :dob, desc: :name]
  - [asc: :dob, desc: :name] - _explicit_

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
