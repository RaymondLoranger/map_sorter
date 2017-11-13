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

  require MapSorter

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
    people_bad_specs = [ask: :dob, desk: :likes]
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
    keywords_bad_specs = %{asc: :dob, desc: :likes}
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
    mixed_bags_bad_specs = {:desc, ~D[2003-03-03], {1.0}}
    mixed_bags_sorted = [
      %{{1.0} => {"5"}, ['2'] => ['5'], ~D[2003-03-03] => ~T[14:30:55]},
      %{{1.0} => {"4"}, ['2'] => ['4'], ~D[2003-03-03] => ~T[14:30:52]},
      %{{1.0} => {"3"}, ['2'] => ['3'], ~D[2003-03-03] => ~T[14:30:52]},
      %{{1.0} => {"2"}, ['2'] => ['2'], ~D[2003-03-03] => ~T[14:30:52]},
      %{{1.0} => {"1"}, ['2'] => ['1'], ~D[2003-03-03] => ~T[14:30:51]}
    ]
    versions = [
      %{id: "2.0.1-beta" , version: Version.parse!("2.0.1-beta" )},
      %{id: "2.0.1-omega", version: Version.parse!("2.0.1-omega")},
      %{id: "2.0.1-alpha", version: Version.parse!("2.0.1-alpha")}
    ]
    versions_sort_specs = [desc: :version]
    versions_sorted = [
      %{id: "2.0.1-omega", version: Version.parse!("2.0.1-omega")},
      %{id: "2.0.1-beta" , version: Version.parse!("2.0.1-beta" )},
      %{id: "2.0.1-alpha", version: Version.parse!("2.0.1-alpha")}
    ]
    regexs = [
      %{id: "abc.*def"  , regex: ~r/abc.*def/  },
      %{id: "(abc)def$" , regex: ~r/(abc)def$/ },
      %{id: "^abc.*def$", regex: ~r/^abc.*def$/}
    ]
    regexs_sort_specs = [desc: :regex]
    regexs_sorted = [
      %{id: "abc.*def"  , regex: ~r/abc.*def/  },
      %{id: "^abc.*def$", regex: ~r/^abc.*def$/},
      %{id: "(abc)def$" , regex: ~r/(abc)def$/ }
    ]
    nested_data = [
      %{name: [first: "Meg", last: "Hill"], birth: [date: ~D[1977-01-23]]},
      %{name: [first: "Meg", last: "Howe"], birth: [date: ~D[1966-01-23]]},
      %{name: [first: "Joe", last: "Holt"], birth: [date: ~D[1988-01-23]]},
      %{name: [first: "Meg", last: "Hunt"], birth: [date: ~D[1955-01-23]]}
    ]
    nested_data_sort_specs = [asc: [:name, :first], desc: [:birth, :date]]
    nested_data_sorted = [
      %{name: [first: "Joe", last: "Holt"], birth: [date: ~D[1988-01-23]]},
      %{name: [first: "Meg", last: "Hill"], birth: [date: ~D[1977-01-23]]},
      %{name: [first: "Meg", last: "Howe"], birth: [date: ~D[1966-01-23]]},
      %{name: [first: "Meg", last: "Hunt"], birth: [date: ~D[1955-01-23]]}
    ]
    setup = %{
      people:                 people,
      people_sort_specs:      people_sort_specs,
      people_bad_specs:       people_bad_specs,
      people_sorted:          people_sorted,
      keywords:               keywords,
      keywords_sort_specs:    keywords_sort_specs,
      keywords_bad_specs:     keywords_bad_specs,
      keywords_sorted:        keywords_sorted,
      mixed_bags:             mixed_bags,
      mixed_bags_sort_specs:  mixed_bags_sort_specs,
      mixed_bags_bad_specs:   mixed_bags_bad_specs,
      mixed_bags_sorted:      mixed_bags_sorted,
      versions:               versions,
      versions_sort_specs:    versions_sort_specs,
      versions_sorted:        versions_sorted,
      regexs:                 regexs,
      regexs_sort_specs:      regexs_sort_specs,
      regexs_sorted:          regexs_sorted,
      nested_data:            nested_data,
      nested_data_sort_specs: nested_data_sort_specs,
      nested_data_sorted:     nested_data_sorted
    }
    {:ok, setup: setup}
  end

  describe "MapSorter.sort/2" do
    test "sorts structs implementing the Access behaviour", %{setup: setup} do
      people = setup.people
      sort_specs = setup.people_sort_specs
      people_sorted = setup.people_sorted
      assert MapSorter.sort(people, sort_specs) == people_sorted
    end

    test "structs not sorted given bad specs", %{setup: setup} do
      people = setup.people
      bad_specs = setup.people_bad_specs
      assert MapSorter.sort(people, bad_specs) == people
      assert MapSorter.sort(people, nil      ) == people
      assert MapSorter.sort(people, []       ) == people
    end

    test "sorts keywords", %{setup: setup} do
      keywords = setup.keywords
      sort_specs = setup.keywords_sort_specs
      keywords_sorted = setup.keywords_sorted
      assert MapSorter.sort(keywords, sort_specs) == keywords_sorted
    end

    test "keywords not sorted given bad specs", %{setup: setup} do
      keywords = setup.keywords
      bad_specs = setup.keywords_bad_specs
      assert MapSorter.sort(keywords, bad_specs) == keywords
      assert MapSorter.sort(keywords, nil      ) == keywords
      assert MapSorter.sort(keywords, []       ) == keywords
    end

    @tag :sorting_on_structs
    test "sorts maps on Time structs", %{setup: setup} do
      mixed_bags = setup.mixed_bags
      sort_specs = setup.mixed_bags_sort_specs
      mixed_bags_sorted = setup.mixed_bags_sorted
      assert MapSorter.sort(mixed_bags, sort_specs) == mixed_bags_sorted
    end

    @tag :sorting_on_structs
    test "maps not sorted given bad specs", %{setup: setup} do
      mixed_bags = setup.mixed_bags
      bad_specs = setup.mixed_bags_bad_specs
      assert MapSorter.sort(mixed_bags, bad_specs) == mixed_bags
      assert MapSorter.sort(mixed_bags, nil      ) == mixed_bags
      assert MapSorter.sort(mixed_bags, []       ) == mixed_bags
    end

    @tag :sorting_on_structs
    test "sorts maps on Version structs", %{setup: setup} do
      versions = setup.versions
      sort_specs = setup.versions_sort_specs
      versions_sorted = setup.versions_sorted
      assert MapSorter.sort(versions, sort_specs) == versions_sorted
    end

    @tag :sorting_on_structs
    test "sorts maps on Regex structs", %{setup: setup} do
      regexs = setup.regexs
      sort_specs = setup.regexs_sort_specs
      regexs_sorted = setup.regexs_sorted
      assert MapSorter.sort(regexs, sort_specs) == regexs_sorted
    end

    @tag :sorting_on_structs
    test "sorts nested data structures", %{setup: setup} do
      nested_data = setup.nested_data
      sort_specs = setup.nested_data_sort_specs
      nested_data_sorted = setup.nested_data_sorted
      assert MapSorter.sort(nested_data, sort_specs) == nested_data_sorted
    end
  end
end
