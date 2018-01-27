defmodule MapSorter.IE do
  @moduledoc false

  # Functions for iex session...
  #
  # Examples:
  #
  #   use MapSorter.IE
  #   people()
  #   sort(people(), asc: :dob, desc: :likes)
  #   Application.put_env(:map_sorter, :sorting_on_structs?, true)
  #   r(SortSpec)
  #   people()
  #   sort(people(), asc: :dob, desc: :likes)
  #   people_as_keywords()
  #   sort(people_as_keywords(), asc: :dob, desc: :likes)
  #   to_comp_fun([:dob, desc: :likes])
  #   to_quoted([:dob, desc: :likes])
  #   to_quoted(quote do: Tuple.to_list({:dob, {:desc, :likes}}))
  #   to_quoted({:dob, :likes})
  #   to_quoted({:dob, :likes, :name})
  #   to_quoted(%{asc: :dob, desc: :likes, ask: :name})
  #   to_quoted(3.1416)
  #   adapt_string("&1[~D[2017-11-02]] < ...", true)
  #   adapt_string("&1[~D[2017-11-02]] < ...", false)

  alias MapSorter.SortSpec

  require MapSorter

  @people [
    %{name: "Mike", likes: "ski, arts", dob: ~D[1992-04-15]},
    %{name: "Mary", likes: "travels", dob: ~D[1992-04-15]},
    %{name: "Bill", likes: "karate", dob: ~D[1977-08-28]},
    %{name: "Joe", likes: "boxing", dob: ~D[1977-08-28]},
    %{name: "Jill", likes: "cooking", dob: ~D[1976-09-28]}
  ]

  defmacro __using__(_options) do
    quote do
      import MapSorter.IE
      alias MapSorter.SortSpec
      require MapSorter
      :ok
    end
  end

  def people(), do: @people

  def people_as_keywords() do
    Enum.map(@people, &Keyword.new/1)
  end

  # Delegation only works with functions...
  def sort(maps, sort_specs), do: MapSorter.sort(maps, sort_specs)

  defdelegate adapt_string(string, sorting_on_structs?), to: SortSpec
  defdelegate to_comp_fun(sort_specs), to: SortSpec
  defdelegate to_quoted(sort_specs), to: SortSpec
end
