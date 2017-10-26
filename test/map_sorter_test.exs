defmodule Person do
  @moduledoc false

  @behaviour Access

  defstruct [:name, :likes, :dob]

  def fetch(person, key) do
    Map.fetch(person, key)
  end

  def get(person, key, default \\ nil) do
    Map.get(person, key, default)
  end

  def get_and_update(person, key, fun) do
    Map.get_and_update(person, key, fun)
  end

  def pop(person, key) do
    Map.pop(person, key)
  end
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
    sorted_people = [
      %Person{name: "Jill", likes: "cooking"  , dob: "1976-09-28"},
      %Person{name: "Bill", likes: "karate"   , dob: "1977-08-28"},
      %Person{name: "Ray" , likes: "cycling"  , dob: "1977-08-28"},
      %Person{name: "Joe" , likes: "boxing"   , dob: "1977-08-28"},
      %Person{name: "Mary", likes: "travels"  , dob: "1992-04-15"},
      %Person{name: "Mike", likes: "ski, arts", dob: "1992-04-15"},
      %Person{name: "Ann" , likes: "reading"  , dob: "1992-04-15"}
    ]
    {:ok, people: people, sorted_people: sorted_people}
  end

  describe "sort/2" do
    test "sorts structs implementing the Access behaviour",
         %{people: people, sorted_people: sorted_people} do
      assert MapSorter.sort(people, asc: :dob, desc: :likes) == sorted_people
    end
  end
end
