defmodule MapSorterTest do
  use ExUnit.Case, async: false

  require MapSorter

  doctest MapSorter, only: TestHelper.doctests(MapSorter)

  setup_all do: SetupTest.setup_all(__MODULE__)

  describe "MapSorter.sort/2" do
    @tag :map_sorter_test_1
    test "sorts structs given explicit specs", context do
      people_sorted = MapSorter.sort(context.people, asc: :dob, desc: :likes)
      assert people_sorted == context.people_sorted
    end

    @tag :map_sorter_test_2
    test "sorts structs given mixed specs", context do
      people_sorted = MapSorter.sort(context.people, [:dob, desc: :likes])
      assert people_sorted == context.people_sorted
    end

    @tag :map_sorter_test_3
    test "sorts structs given runtime specs", context do
      people_sorted = MapSorter.sort(context.people, context.people_sort_specs)
      assert people_sorted == context.people_sorted
    end

    @tag :map_sorter_test_4
    test "structs not sorted given map specs", context do
      people_sorted = MapSorter.sort(context.people, %{asc: :dob, desc: :likes})
      assert people_sorted == context.people
    end

    @tag :map_sorter_test_5
    test "structs not sorted given bad runtime specs", context do
      bad_specs = [ask: :dob, desk: :likes]
      people_sorted = MapSorter.sort(context.people, bad_specs)
      assert people_sorted == context.people
    end

    @tag :map_sorter_test_6
    test "structs not sorted given bad compile time specs", context do
      people_sorted = MapSorter.sort(context.people, ask: :dob, desk: :likes)
      assert people_sorted == context.people
    end

    @tag :map_sorter_test_7
    test "structs not sorted given empty list specs", context do
      assert MapSorter.sort(context.people, []) == context.people
    end

    @tag :map_sorter_test_8
    test "structs not sorted given nil specs", context do
      assert MapSorter.sort(context.people, nil) == context.people
    end

    @tag :map_sorter_test_9
    test "sorts structs implementing the Access behaviour", context do
      people = context.people
      sort_specs = context.people_sort_specs
      people_sorted = context.people_sorted
      assert MapSorter.sort(people, sort_specs) == people_sorted
    end

    @tag :map_sorter_test_10
    test "sorts keywords", context do
      keywords = context.keywords
      sort_specs = context.keywords_sort_specs
      keywords_sorted = context.keywords_sorted
      assert MapSorter.sort(keywords, sort_specs) == keywords_sorted
    end

    @tag :map_sorter_test_11
    test "keywords not sorted given map specs", context do
      keywords = context.keywords
      bad_specs = %{asc: :dob, desc: :likes}
      assert MapSorter.sort(keywords, bad_specs) == keywords
    end

    @tag :map_sorter_test_12
    test "keywords not sorted given nil specs", context do
      keywords = context.keywords
      assert MapSorter.sort(keywords, nil) == keywords
    end

    @tag :map_sorter_test_13
    test "keywords not sorted given empty list specs", context do
      keywords = context.keywords
      assert MapSorter.sort(keywords, []) == keywords
    end

    @tag :map_sorter_test_14
    test "sorts maps on Time structs", context do
      mixed_bags = context.mixed_bags
      sort_specs = context.mixed_bags_sort_specs
      mixed_bags_sorted = context.mixed_bags_sorted
      assert MapSorter.sort(mixed_bags, sort_specs) == mixed_bags_sorted
    end

    @tag :map_sorter_test_15
    test "maps not sorted given tuple specs", context do
      mixed_bags = context.mixed_bags
      bad_specs = {:desc, ~D[2003-03-03], {1.0}}
      assert MapSorter.sort(mixed_bags, bad_specs) == mixed_bags
    end

    @tag :map_sorter_test_16
    test "maps not sorted given nil specs", context do
      mixed_bags = context.mixed_bags
      assert MapSorter.sort(mixed_bags, nil) == mixed_bags
    end

    @tag :map_sorter_test_17
    test "maps not sorted given empty list specs", context do
      mixed_bags = context.mixed_bags
      assert MapSorter.sort(mixed_bags, []) == mixed_bags
    end

    @tag :map_sorter_test_18
    test "sorts maps on Version structs", context do
      versions = context.versions
      sort_specs = context.versions_sort_specs
      versions_sorted = context.versions_sorted
      assert MapSorter.sort(versions, sort_specs) == versions_sorted
    end

    @tag :map_sorter_test_19
    test "sorts maps on Regex structs", context do
      regexs = context.regexs
      sort_specs = context.regexs_sort_specs
      regexs_sorted = context.regexs_sorted
      assert MapSorter.sort(regexs, sort_specs) == regexs_sorted
    end

    @tag :map_sorter_test_20
    test "sorts on Date or NaiveDateTime given runtime specs", context do
      clients = context.clients
      specs = context.clients_sort_specs
      clients_sorted = context.clients_sorted
      assert MapSorter.sort(clients, specs) == clients_sorted
    end

    @tag :map_sorter_test_21
    test "sorts on Date or NaiveDateTime given compile time specs", context do
      clients = context.clients
      sorted = context.clients_sorted
      assert MapSorter.sort(clients, asc: {:dob, Date}, desc: :likes) == sorted
    end

    @tag :map_sorter_test_22
    test "sorts NOT on Date structs given bad key at runtime", context do
      clients = context.clients
      bad_key_specs = [{'--dob--', Date}, desc: :likes]
      badly_sorted = MapSorter.sort(clients, bad_key_specs)
      assert MapSorter.sort(clients, desc: :likes) == badly_sorted
    end

    @tag :map_sorter_test_23
    test "sorts NOT on Date structs given bad key at compile time", context do
      clients = context.clients
      badly_sorted = MapSorter.sort(clients, [{'--dob--', Date}, desc: :likes])
      assert MapSorter.sort(clients, desc: :likes) == badly_sorted
    end

    @tag :map_sorter_test_24
    test "sorts nested data structures", context do
      nested_data = context.nested_data
      sort_specs = context.nested_data_sort_specs
      nested_data_sorted = context.nested_data_sorted
      assert MapSorter.sort(nested_data, sort_specs) == nested_data_sorted
    end
  end
end
