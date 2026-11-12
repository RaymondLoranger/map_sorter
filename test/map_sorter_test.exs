defmodule MapSorterTest do
  use ExUnit.Case, async: true
  use PersistConfig

  require MapSorter

  @included_tags get_env(:included_tags)

  if :map_sorter_test_1 in @included_tags do
    @people_sort_specs [asc: :dob, desc: :likes]
  end

  doctest MapSorter, only: TestHelper.doctests(MapSorter)

  setup_all do: TestHelper.Context.setup_all(__MODULE__)

  describe "MapSorter.sort/2" do
    if :map_sorter_test_1 in @included_tags do
      test "sorts structs given explicit specs", context do
        people_sorted = MapSorter.sort(context.people, asc: :dob, desc: :likes)
        assert people_sorted == context.people_sorted
        people_sorted = MapSorter.sort(context.people, @people_sort_specs)
        assert people_sorted == context.people_sorted
      end
    end

    if :map_sorter_test_2 in @included_tags do
      test "sorts structs given mixed specs", context do
        people_sorted = MapSorter.sort(context.people, [:dob, desc: :likes])
        assert people_sorted == context.people_sorted
      end
    end

    if :map_sorter_test_3 in @included_tags do
      test "sorts structs given runtime specs", context do
        import MapSorter, only: [sort: 2]

        people_sorted = sort(context.people, context.people_sort_specs)
        indeed_sorted = sort(context.people, context.superfluous_specs)
        assert people_sorted == context.people_sorted
        assert indeed_sorted == context.people_sorted
      end
    end

    if :map_sorter_test_4 in @included_tags do
      test "sorts NOT structs given map specs", context do
        import MapSorter, only: [sort: 2]

        people_sorted = sort(context.people, %{asc: :dob, desc: :likes})
        assert people_sorted == context.people
      end
    end

    if :map_sorter_test_5 in @included_tags do
      test "sorts NOT structs given tuple specs", context do
        people_sorted = MapSorter.sort(context.people, {:dob, desc: :likes})
        assert people_sorted == context.people
      end
    end

    if :map_sorter_test_6 in @included_tags do
      test "sorts NOT structs given bad runtime specs", context do
        bad_specs = [ask: :dob, desk: :likes]
        people_sorted = MapSorter.sort(context.people, bad_specs)
        assert people_sorted == context.people
      end
    end

    if :map_sorter_test_7 in @included_tags do
      test "sorts NOT structs given bad compile time specs", context do
        people_sorted = MapSorter.sort(context.people, ask: :dob, desk: :likes)
        assert people_sorted == context.people
      end
    end

    if :map_sorter_test_8 in @included_tags do
      test "sorts NOT structs given empty list specs", context do
        assert MapSorter.sort(context.people, []) == context.people
      end
    end

    if :map_sorter_test_9 in @included_tags do
      test "sorts NOT structs given nil specs", context do
        assert MapSorter.sort(context.people, nil) == context.people
      end
    end

    if :map_sorter_test_10 in @included_tags do
      test "sorts structs implementing the Access behaviour", context do
        people = context.people
        sort_specs = context.people_sort_specs
        people_sorted = context.people_sorted
        assert MapSorter.sort(people, sort_specs) == people_sorted
      end
    end

    if :map_sorter_test_11 in @included_tags do
      test "sorts keywords", context do
        keywords = context.keywords
        sort_specs = context.keywords_sort_specs
        keywords_sorted = context.keywords_sorted
        assert MapSorter.sort(keywords, sort_specs) == keywords_sorted
      end
    end

    if :map_sorter_test_12 in @included_tags do
      test "sorts NOT keywords given map specs", context do
        keywords = context.keywords
        bad_specs = %{asc: :dob, desc: :likes}
        assert MapSorter.sort(keywords, bad_specs) == keywords
      end
    end

    if :map_sorter_test_13 in @included_tags do
      test "sorts NOT keywords given nil specs", context do
        keywords = context.keywords
        assert MapSorter.sort(keywords, nil) == keywords
      end
    end

    if :map_sorter_test_14 in @included_tags do
      test "sorts NOT keywords given empty list specs", context do
        keywords = context.keywords
        assert MapSorter.sort(keywords, []) == keywords
      end
    end

    if :map_sorter_test_15 in @included_tags do
      test "sorts maps on Time structs", context do
        mixed_bags = context.mixed_bags
        sort_specs = context.mixed_bags_sort_specs
        mixed_bags_sorted = context.mixed_bags_sorted
        assert MapSorter.sort(mixed_bags, sort_specs) == mixed_bags_sorted
      end
    end

    if :map_sorter_test_16 in @included_tags do
      test "sorts NOT maps given tuple specs", context do
        mixed_bags = context.mixed_bags
        bad_specs = {:desc, ~D[2003-03-03], {1.0}}
        assert MapSorter.sort(mixed_bags, bad_specs) == mixed_bags
      end
    end

    if :map_sorter_test_17 in @included_tags do
      test "sorts NOT maps given nil specs", context do
        mixed_bags = context.mixed_bags
        assert MapSorter.sort(mixed_bags, nil) == mixed_bags
      end
    end

    if :map_sorter_test_18 in @included_tags do
      test "sorts NOT maps given empty list specs", context do
        mixed_bags = context.mixed_bags
        assert MapSorter.sort(mixed_bags, []) == mixed_bags
      end
    end

    if :map_sorter_test_19 in @included_tags do
      test "sorts maps on Version structs", context do
        versions = context.versions
        sort_specs = context.versions_sort_specs
        versions_sorted = context.versions_sorted
        assert MapSorter.sort(versions, sort_specs) == versions_sorted
      end
    end

    if :map_sorter_test_20 in @included_tags do
      test "sorts maps on Range structs", context do
        ranges = context.ranges
        sort_specs = context.ranges_sort_specs
        ranges_sorted = context.ranges_sorted
        assert MapSorter.sort(ranges, sort_specs) == ranges_sorted
      end
    end

    if :map_sorter_test_21 in @included_tags do
      test "sorts on Date or NaiveDateTime given runtime specs", context do
        clients = context.clients
        specs = context.clients_sort_specs
        clients_sorted = context.clients_sorted
        assert MapSorter.sort(clients, specs) == clients_sorted
      end
    end

    if :map_sorter_test_22 in @included_tags do
      test "sorts on Date or NaiveDateTime given compile time specs", context do
        import MapSorter, only: [sort: 2]

        clients = context.clients
        sorted = context.clients_sorted
        assert sort(clients, asc: {:dob, Date}, desc: :likes) == sorted
      end
    end

    if :map_sorter_test_23 in @included_tags do
      test "sorts NOT on Date structs given bad key at runtime", context do
        clients = context.clients
        bad_key_specs = [{DOB, Date}, desc: :likes]
        badly_sorted = MapSorter.sort(clients, bad_key_specs)
        assert MapSorter.sort(clients, desc: :likes) == badly_sorted
      end
    end

    if :map_sorter_test_24 in @included_tags do
      test "sorts NOT on Date structs given bad key at compile time", context do
        clients = context.clients
        badly_sorted = MapSorter.sort(clients, [{DOB, Date}, desc: :likes])
        assert MapSorter.sort(clients, desc: :likes) == badly_sorted
      end
    end

    if :map_sorter_test_25 in @included_tags do
      test "sorts nested data structures", context do
        nested_data = context.nested_data
        sort_specs = context.nested_data_sort_specs
        nested_data_sorted = context.nested_data_sorted
        assert MapSorter.sort(nested_data, sort_specs) == nested_data_sorted
      end
    end
  end

  describe "config/runtime.exs overrides config/config.exs" do
    if :map_sorter_test_26 in @included_tags do
      require Logger

      @env get_env(:env)

      test "runtime.exs if present overrides config.exs" do
        if File.exists?("config/runtime.exs") do
          Logger.notice("'config/runtime.exs' exists...")
          Logger.notice("env is #{@env}")
          assert @env == "test ➔ from config/runtime.exs"
        else
          Logger.notice("'config/runtime.exs' does not exist...")
          Logger.notice("env is #{@env}")
          assert @env == "test ➔ from config/config.exs"
        end
      end
    end
  end
end
