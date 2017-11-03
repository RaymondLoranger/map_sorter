defmodule Person do
  @moduledoc false

  @behaviour Access

  defstruct [:name, :likes, :dob]

  defdelegate fetch(person, key), to: Map
  defdelegate get(person, key, default), to: Map
  defdelegate get_and_update(person, key, fun), to: Map
  defdelegate pop(person, key), to: Map
end

defmodule MapSorterTest do
  @moduledoc false

  use ExUnit.Case, async: false

  doctest MapSorter

  setup_all do
    people = [
      %Person{name: "Mike", likes: "ski, arts", dob: "1992-04-15"},
      %Person{name: "Mary", likes: "travels"  , dob: "1992-04-15"},
      %Person{name: "Ann" , likes: "reading"  , dob: "1992-04-15"},
      %Person{name: "Ray" , likes: "cycling"  , dob: "1977-08-28"},
      %Person{name: "Bill", likes: "karate"   , dob: "1977-08-28"},
      %Person{name: "Joe" , likes: "boxing"   , dob: "1977-08-28"},
      %Person{name: "Jill", likes: "cooking"  , dob: "1976-09-28"}
    ]
    people_sort_specs = [asc: :dob, desc: :likes]
    people_sorted = [
      %Person{name: "Jill", likes: "cooking"  , dob: "1976-09-28"},
      %Person{name: "Bill", likes: "karate"   , dob: "1977-08-28"},
      %Person{name: "Ray" , likes: "cycling"  , dob: "1977-08-28"},
      %Person{name: "Joe" , likes: "boxing"   , dob: "1977-08-28"},
      %Person{name: "Mary", likes: "travels"  , dob: "1992-04-15"},
      %Person{name: "Mike", likes: "ski, arts", dob: "1992-04-15"},
      %Person{name: "Ann" , likes: "reading"  , dob: "1992-04-15"}
    ]
    keywords = [
      [name: "Mike", likes: "ski, arts", dob: "1992-04-15"],
      [name: "Mary", likes: "travels"  , dob: "1992-04-15"],
      [name: "Ann" , likes: "reading"  , dob: "1992-04-15"],
      [name: "Ray" , likes: "cycling"  , dob: "1977-08-28"],
      [name: "Bill", likes: "karate"   , dob: "1977-08-28"],
      [name: "Joe" , likes: "boxing"   , dob: "1977-08-28"],
      [name: "Jill", likes: "cooking"  , dob: "1976-09-28"]
    ]
    keywords_sort_specs = [asc: :dob, desc: :likes]
    keywords_sorted = [
      [name: "Jill", likes: "cooking"  , dob: "1976-09-28"],
      [name: "Bill", likes: "karate"   , dob: "1977-08-28"],
      [name: "Ray" , likes: "cycling"  , dob: "1977-08-28"],
      [name: "Joe" , likes: "boxing"   , dob: "1977-08-28"],
      [name: "Mary", likes: "travels"  , dob: "1992-04-15"],
      [name: "Mike", likes: "ski, arts", dob: "1992-04-15"],
      [name: "Ann" , likes: "reading"  , dob: "1992-04-15"]
    ]
    mixed_bags = [
      %{{1.0} => {"1"}, ['2'] => ['1'], ~D[2003-03-03] => ~T[14:30:51]},
      %{{1.0} => {"2"}, ['2'] => ['2'], ~D[2003-03-03] => ~T[14:30:52]},
      %{{1.0} => {"3"}, ['2'] => ['3'], ~D[2003-03-03] => ~T[14:30:52]},
      %{{1.0} => {"4"}, ['2'] => ['4'], ~D[2003-03-03] => ~T[14:30:52]},
      %{{1.0} => {"5"}, ['2'] => ['5'], ~D[2003-03-03] => ~T[14:30:55]}
    ]
    mixed_bags_sort_specs = [desc: ~D[2003-03-03], desc: {1.0}]
    mixed_bags_sorted = [
      %{{1.0} => {"5"}, ['2'] => ['5'], ~D[2003-03-03] => ~T[14:30:55]},
      %{{1.0} => {"4"}, ['2'] => ['4'], ~D[2003-03-03] => ~T[14:30:52]},
      %{{1.0} => {"3"}, ['2'] => ['3'], ~D[2003-03-03] => ~T[14:30:52]},
      %{{1.0} => {"2"}, ['2'] => ['2'], ~D[2003-03-03] => ~T[14:30:52]},
      %{{1.0} => {"1"}, ['2'] => ['1'], ~D[2003-03-03] => ~T[14:30:51]}
    ]
    setup = %{
      people:                people,
      people_sort_specs:     people_sort_specs,
      people_sorted:         people_sorted,
      keywords:              keywords,
      keywords_sort_specs:   keywords_sort_specs,
      keywords_sorted:       keywords_sorted,
      mixed_bags:            mixed_bags,
      mixed_bags_sort_specs: mixed_bags_sort_specs,
      mixed_bags_sorted:     mixed_bags_sorted
    }
    {:ok, setup: setup}
  end

  describe "sort/2" do
    test "sorts structs implementing the Access behaviour", %{setup: setup} do
      people = setup.people
      sort_specs = setup.people_sort_specs
      people_sorted = setup.people_sorted
      assert MapSorter.sort(people, sort_specs) == people_sorted
    end

    test "sorts keywords", %{setup: setup} do
      keywords = setup.keywords
      sort_specs = setup.keywords_sort_specs
      keywords_sorted = setup.keywords_sorted
      assert MapSorter.sort(keywords, sort_specs) == keywords_sorted
    end

    test "sorts maps with any keys or values", %{setup: setup} do
      mixed_bags = setup.mixed_bags
      sort_specs = setup.mixed_bags_sort_specs
      mixed_bags_sorted = setup.mixed_bags_sorted
      assert MapSorter.sort(mixed_bags, sort_specs) == mixed_bags_sorted
    end
  end
end
