# Map Sorter

**Generates the AST to sort maps per sort specs (ascending/descending keys).**

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

Takes a list of `maps` and either a list of `sort specs` or an AST
that will evaluate to a list of `sort specs` at runtime.

Returns the AST to sort the `maps` per the `sort specs`.

`sort specs` can be implicit, explicit or mixed:

- [:dob, :name] is implicit ⇒ [asc: :dob, asc: :name]
- [:dob, desc: :name] is mixed ⇒ [asc: :dob, desc: :name]
- [asc: :dob, desc: :name] is explicit

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
