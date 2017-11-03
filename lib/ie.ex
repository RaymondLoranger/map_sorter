defmodule IE do
  @moduledoc false

  alias MapSorter.Support

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
  #   sort(people(), asc: :dob, desc: :name)
  #   sort(people_as_keywords(), asc: :dob, desc: :name)
  #   sort(people(), desc: :dob, asc: :likes)
  #   sort(people_as_keywords(), desc: :dob, asc: :likes)
  #   sort(people(), desc: :dob, asc: :name)
  #   sort(people_as_keywords(), desc: :dob, asc: :name)
  #   eval_sort_fun([:dob, desc: :likes])
  #   sort_fun_ast([:dob, desc: :likes])
  #   sort_fun_ast(quote do: Tuple.to_list({:dob, {:desc, :likes}}))
  #   adapt("&1[:dob] < ...\n&2[:likes] -> ...") |> IO.puts()
  #   adapt("&1[~D[2017-11-02]] < ...") |> IO.puts()

  defmacro use() do
    quote do
      import IE
      alias MapSorter.Support
      require MapSorter
      :ok
    end
  end

  def people(), do: @people

  def people_as_keywords() do
    Enum.map(@people, &Keyword.new/1)
  end

  def sort(maps, sort_specs), do: MapSorter.sort(maps, sort_specs)

  defdelegate eval_sort_fun(sort_specs), to: Support

  defdelegate sort_fun_ast(sort_specs), to: Support

  defdelegate adapt(string), to: Support
end
