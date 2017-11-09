defmodule IE do
  @moduledoc false

  alias MapSorter.Impl

  require MapSorter

  @people [
    %{name: "Mike", likes: "ski, arts", dob: ~D[1992-04-15]},
    %{name: "Mary", likes: "travels"  , dob: ~D[1992-04-15]},
    %{name: "Ann" , likes: "reading"  , dob: ~D[1992-04-15]},
    %{name: "Ray" , likes: "cycling"  , dob: ~D[1977-08-28]},
    %{name: "Bill", likes: "karate"   , dob: ~D[1977-08-28]},
    %{name: "Joe" , likes: "boxing"   , dob: ~D[1977-08-28]},
    %{name: "Jill", likes: "cooking"  , dob: ~D[1976-09-28]}
  ]

  # Functions for iex session...
  #
  # Examples:
  #   require IE
  #   IE.use
  #   people()
  #   people_as_keywords()
  #   sort(people(), asc: :dob, desc: :likes)
  #   sort(people_as_keywords(), asc: :dob, desc: :likes)
  #   eval_sort_fun([:dob, desc: :likes])
  #   sort_fun([:dob, desc: :likes])
  #   sort_fun(quote do: Tuple.to_list({:dob, {:desc, :likes}}))
  #   adapt("&1[~D[2017-11-02]] < ...") |> IO.puts()

  defmacro use() do
    quote do
      import IE
      alias MapSorter.Impl
      require MapSorter
      :ok
    end
  end

  def people(), do: @people

  def people_as_keywords() do
    Enum.map(@people, &Keyword.new/1)
  end

  def sort(maps, sort_specs), do: MapSorter.sort(maps, sort_specs)

  defdelegate adapt(string), to: Impl
  defdelegate eval_sort_fun(sort_specs), to: Impl
  defdelegate sort_fun(sort_specs), to: Impl
end
