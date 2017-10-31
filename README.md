# Map Sorter

Sorts a list of `maps`¹ as per a list of sort specs
(ascending/descending keys).

¹<em>Or keywords or structures implementing the Access behaviour.</em>
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

Takes a list of `maps`¹ and either a list of `sort specs` or an AST
that will evaluate to a list of `sort specs` at runtime.

Returns the AST to sort the `maps`¹ as per the `sort specs`.

`sort specs` can be implicit, explicit or mixed:

- [:dob, :name] is <em>implicit</em> and same as ⟹ [asc: :dob, asc: :name]
- [:dob, desc: :name] is <em>mixed</em> and like ⟹ [asc: :dob, desc: :name]
- [asc: :dob, desc: :name] is <em>explicit</em>

¹<em>Or keywords or structures implementing the Access behaviour.</em>

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
MapSorter.sort(people, asc: :dob, desc: :likes),
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
