defmodule MapSorter do
  @moduledoc """
  Generates the AST to sort maps as per sort specs (ascending/descending keys).
  """

  require Logger

  @doc """
  Takes a list of `maps` and either a list of `sort specs` or an AST
  that will evaluate to a list of `sort specs` at runtime.

  Returns the AST to sort the `maps` as per the `sort specs`.

  `sort specs` can be implicit, explicit or mixed:

  - [:dob, :name] is implicit ⇒ [asc: :dob, asc: :name]
  - [:dob, desc: :name] is mixed ⇒ [asc: :dob, desc: :name]
  - [asc: :dob, desc: :name] is explicit

  ## Examples

      iex> require MapSorter
      iex> people = [
      ...>   %{name: "Mike", likes: "ski, arts", dob: "1992-04-15"},
      ...>   %{name: "Mary", likes: "travels"  , dob: "1992-04-15"},
      ...>   %{name: "Ann" , likes: "reading"  , dob: "1992-04-15"},
      ...>   %{name: "Ray" , likes: "cycling"  , dob: "1977-08-28"},
      ...>   %{name: "Bill", likes: "karate"   , dob: "1977-08-28"},
      ...>   %{name: "Joe" , likes: "boxing"   , dob: "1977-08-28"},
      ...>   %{name: "Jill", likes: "cooking"  , dob: "1976-09-28"}
      ...> ]
      iex> MapSorter.log_level(:info) # :debug ⇒ debug messages
      iex> fun = & &1
      iex> sorted = %{
      ...>   explicit: MapSorter.sort(people, asc: :dob, desc: :likes),
      ...>   implicit: MapSorter.sort(people, [:dob, desc: :likes]),
      ...>   function: MapSorter.sort(people, fun.([:dob, desc: :likes]))
      ...> }
      iex> MapSorter.log_level(:info) # :info ⇒ no debug messages
      iex> sorted.explicit == sorted.implicit and
      ...> sorted.explicit == sorted.function and
      ...> sorted.explicit
      [
        %{name: "Jill", likes: "cooking"  , dob: "1976-09-28"},
        %{name: "Bill", likes: "karate"   , dob: "1977-08-28"},
        %{name: "Ray" , likes: "cycling"  , dob: "1977-08-28"},
        %{name: "Joe" , likes: "boxing"   , dob: "1977-08-28"},
        %{name: "Mary", likes: "travels"  , dob: "1992-04-15"},
        %{name: "Mike", likes: "ski, arts", dob: "1992-04-15"},
        %{name: "Ann" , likes: "reading"  , dob: "1992-04-15"}
      ]
  """
  defmacro sort(maps, sort_specs) do
    Logger.debug("sort specs: #{inspect sort_specs}...")
    sort_fun_ast =
      case sort_specs do
        specs when is_list(specs) -> specs
        specs -> Macro.expand(specs, __CALLER__) # in case module attribute
      end
      |> MapSorter.Support.sort_fun_ast()
    quote do: Enum.sort(unquote(maps), unquote(sort_fun_ast))
  end

  @doc """
  Allows to change the log `level` at compile time.
  """
  defmacro log_level(level), do: Logger.configure(level: level)
end
