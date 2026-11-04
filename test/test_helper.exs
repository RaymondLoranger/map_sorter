defmodule TestHelper do
  use PersistConfig

  @spec doctests(module) :: [Macro.Env.name_arity()]
  def doctests(test_module) when is_atom(test_module) do
    get_env(:doctests, %{})[test_module] || []
  end
end

ExUnit.start()

defmodule TestHelper.Context do
  defmodule Person do
    @behaviour Access

    defstruct [:name, :likes, :dob]

    @impl Access
    defdelegate fetch(person, key), to: Map
    @impl Access
    defdelegate get_and_update(person, key, fun), to: Map
    @impl Access
    defdelegate pop(person, key), to: Map
  end

  @spec setup_all(module) :: map
  def setup_all(test_module)

  def setup_all(MapSorterTest) do
    people = [
      %Person{name: "Mike", likes: "ski, arts", dob: "1992-04-15"},
      %Person{name: "Mary", likes: "travels", dob: "1992-04-15"},
      %Person{name: "Ann", likes: "reading", dob: "1992-04-15"},
      %Person{name: "Ray", likes: "cycling", dob: "1977-08-28"},
      %Person{name: "Bill", likes: "karate", dob: "1977-08-28"},
      %Person{name: "Joe", likes: "boxing", dob: "1977-08-28"},
      %Person{name: "Jill", likes: "cooking", dob: "1976-09-28"}
    ]

    people_sort_specs = [asc: :dob, desc: :likes]
    partly_sort_specs = [asc: :dob, asc: :what, desc: :likes, desc: :where]

    people_sorted = [
      %Person{name: "Jill", likes: "cooking", dob: "1976-09-28"},
      %Person{name: "Bill", likes: "karate", dob: "1977-08-28"},
      %Person{name: "Ray", likes: "cycling", dob: "1977-08-28"},
      %Person{name: "Joe", likes: "boxing", dob: "1977-08-28"},
      %Person{name: "Mary", likes: "travels", dob: "1992-04-15"},
      %Person{name: "Mike", likes: "ski, arts", dob: "1992-04-15"},
      %Person{name: "Ann", likes: "reading", dob: "1992-04-15"}
    ]

    keywords = [
      [name: "Mike", likes: "ski, arts", dob: "1992-04-15"],
      [name: "Mary", likes: "travels", dob: "1992-04-15"],
      [name: "Ann", likes: "reading", dob: "1992-04-15"],
      [name: "Ray", likes: "cycling", dob: "1977-08-28"],
      [name: "Bill", likes: "karate", dob: "1977-08-28"],
      [name: "Joe", likes: "boxing", dob: "1977-08-28"],
      [name: "Jill", likes: "cooking", dob: "1976-09-28"]
    ]

    keywords_sort_specs = [asc: :dob, desc: :likes]

    keywords_sorted = [
      [name: "Jill", likes: "cooking", dob: "1976-09-28"],
      [name: "Bill", likes: "karate", dob: "1977-08-28"],
      [name: "Ray", likes: "cycling", dob: "1977-08-28"],
      [name: "Joe", likes: "boxing", dob: "1977-08-28"],
      [name: "Mary", likes: "travels", dob: "1992-04-15"],
      [name: "Mike", likes: "ski, arts", dob: "1992-04-15"],
      [name: "Ann", likes: "reading", dob: "1992-04-15"]
    ]

    mixed_bags = [
      %{{1.0} => {"1"}, [:"2"] => ["1"], ~D[2003-03-03] => ~T[14:30:51]},
      %{{1.0} => {"2"}, [:"2"] => ["2"], ~D[2003-03-03] => ~T[14:30:52]},
      %{{1.0} => {"3"}, [:"2"] => ["3"], ~D[2003-03-03] => ~T[14:30:52]},
      %{{1.0} => {"4"}, [:"2"] => ["4"], ~D[2003-03-03] => ~T[14:30:52]},
      %{{1.0} => {"5"}, [:"2"] => ["5"], ~D[2003-03-03] => ~T[14:30:55]}
    ]

    mixed_bags_sort_specs = [desc: ~D[2003-03-03], desc: {1.0}]

    mixed_bags_sorted = [
      %{{1.0} => {"5"}, [:"2"] => ["5"], ~D[2003-03-03] => ~T[14:30:55]},
      %{{1.0} => {"4"}, [:"2"] => ["4"], ~D[2003-03-03] => ~T[14:30:52]},
      %{{1.0} => {"3"}, [:"2"] => ["3"], ~D[2003-03-03] => ~T[14:30:52]},
      %{{1.0} => {"2"}, [:"2"] => ["2"], ~D[2003-03-03] => ~T[14:30:52]},
      %{{1.0} => {"1"}, [:"2"] => ["1"], ~D[2003-03-03] => ~T[14:30:51]}
    ]

    versions = [
      %{id: "2.0.1-beta", version: Version.parse!("2.0.1-beta")},
      %{id: "2.0.1-omega", version: Version.parse!("2.0.1-omega")},
      %{id: "2.0.1-alpha", version: Version.parse!("2.0.1-alpha")},
      %{id: "0.0.1", version: Version.parse!("0.0.1")}
    ]

    versions_sort_specs = [desc: {:version, Version}]

    versions_sorted = [
      %{id: "2.0.1-omega", version: Version.parse!("2.0.1-omega")},
      %{id: "2.0.1-beta", version: Version.parse!("2.0.1-beta")},
      %{id: "2.0.1-alpha", version: Version.parse!("2.0.1-alpha")},
      %{id: "0.0.1", version: Version.parse!("0.0.1")}
    ]

    ranges = [
      %{id: "1..9//2", range: 1..9//2},
      %{id: "2..9//2", range: 2..9//2},
      %{id: "1..11//3", range: 1..11//3},
      %{id: "1..11//4", range: 1..11//4},
      %{id: "11..1//-1", range: 11..1//-1}
    ]

    ranges_sort_specs = [asc: {:range, MapSorter.Range}]

    ranges_sorted = [
      %{id: "1..9//2", range: 1..9//2},
      %{id: "1..11//3", range: 1..11//3},
      %{id: "1..11//4", range: 1..11//4},
      %{id: "2..9//2", range: 2..9//2},
      %{id: "11..1//-1", range: 11..1//-1}
    ]

    clients = [
      %Person{name: "Mike", likes: "ski, arts", dob: ~D[1992-04-15]},
      %Person{name: "Mary", likes: "travels", dob: ~N[1992-04-15 23:59:59]},
      %Person{name: "Ann", likes: "reading", dob: ~D[1992-04-15]},
      %Person{name: "Ray", likes: "cycling", dob: ~D[1977-08-28]},
      %Person{name: "Bill", likes: "karate", dob: ~N[1977-08-28 00:00:01]},
      %Person{name: "Joe", likes: "boxing", dob: ~D[1977-08-28]},
      %Person{name: "Jill", likes: "cooking", dob: ~D[1976-09-28]}
    ]

    clients_sort_specs = [asc: {:dob, Date}, desc: :likes]

    clients_sorted = [
      %Person{name: "Jill", likes: "cooking", dob: ~D[1976-09-28]},
      %Person{name: "Bill", likes: "karate", dob: ~N[1977-08-28 00:00:01]},
      %Person{name: "Ray", likes: "cycling", dob: ~D[1977-08-28]},
      %Person{name: "Joe", likes: "boxing", dob: ~D[1977-08-28]},
      %Person{name: "Mary", likes: "travels", dob: ~N[1992-04-15 23:59:59]},
      %Person{name: "Mike", likes: "ski, arts", dob: ~D[1992-04-15]},
      %Person{name: "Ann", likes: "reading", dob: ~D[1992-04-15]}
    ]

    nested_data = [
      %{
        name: [first: "John", last: "Hill"],
        birth: [city: "New York", date: ~D[1977-01-23]]
      },
      %{
        name: [first: "Jill", last: "Howe"],
        birth: [city: "Los Angeles", date: ~N[1977-01-23 01:02:03]]
      },
      %{
        name: [first: "Jay", last: "Holt"],
        birth: [city: "Chicago", date: ~N[1988-01-23 23:59:59]]
      },
      %{
        name: [first: "Jim", last: "Hunt"],
        birth: [city: "Houston", date: ~D[1988-01-23]]
      }
    ]

    nested_data_sort_specs = [
      desc: {[:birth, :date], Date},
      asc: [:name, :last]
    ]

    nested_data_sorted = [
      %{
        name: [first: "Jay", last: "Holt"],
        birth: [city: "Chicago", date: ~N[1988-01-23 23:59:59]]
      },
      %{
        name: [first: "Jim", last: "Hunt"],
        birth: [city: "Houston", date: ~D[1988-01-23]]
      },
      %{
        name: [first: "John", last: "Hill"],
        birth: [city: "New York", date: ~D[1977-01-23]]
      },
      %{
        name: [first: "Jill", last: "Howe"],
        birth: [city: "Los Angeles", date: ~N[1977-01-23 01:02:03]]
      }
    ]

    %{
      people: people,
      people_sort_specs: people_sort_specs,
      partly_sort_specs: partly_sort_specs,
      people_sorted: people_sorted,
      keywords: keywords,
      keywords_sort_specs: keywords_sort_specs,
      keywords_sorted: keywords_sorted,
      mixed_bags: mixed_bags,
      mixed_bags_sort_specs: mixed_bags_sort_specs,
      mixed_bags_sorted: mixed_bags_sorted,
      versions: versions,
      versions_sort_specs: versions_sort_specs,
      versions_sorted: versions_sorted,
      ranges: ranges,
      ranges_sort_specs: ranges_sort_specs,
      ranges_sorted: ranges_sorted,
      clients: clients,
      clients_sort_specs: clients_sort_specs,
      clients_sorted: clients_sorted,
      nested_data: nested_data,
      nested_data_sort_specs: nested_data_sort_specs,
      nested_data_sorted: nested_data_sorted
    }
  end

  def setup_all(test_module)
      when test_module in [MapSorter.SortSpecsTest, MapSorter.CompareTest] do
    true_doc = """
    & cond do
    true -> true or &1 > &2
    end
    """

    {:ok, true_ast} = Code.string_to_quoted(true_doc)
    {true_fun, []} = Code.eval_string(true_doc)

    here_doc = """
    & cond do
    &1[:dob] < &2[:dob] -> true
    &1[:dob] > &2[:dob] -> false
    &1[:likes] > &2[:likes] -> true
    &1[:likes] < &2[:likes] -> false
    true -> true or &1 > &2
    end
    """

    {:ok, here_ast} = Code.string_to_quoted(here_doc)
    {here_fun, []} = Code.eval_string(here_doc)

    sort_specs = [:dob, desc: :likes]
    tuple = List.to_tuple(sort_specs)
    tuple_ast = quote do: Tuple.to_list(unquote(tuple))
    tuple_str = "MapSorter.Compare.fun(Tuple.to_list({:dob, {:desc, :likes}}))"

    %{
      true_ast: true_ast,
      true_fun: true_fun,
      here_ast: here_ast,
      here_fun: here_fun,
      sort_specs: sort_specs,
      tuple: tuple,
      tuple_ast: tuple_ast,
      tuple_str: tuple_str
    }
  end
end
