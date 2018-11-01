defmodule TestHelper do
  use PersistConfig

  def sorting_on_structs? do
    Application.get_env(@app, :sorting_on_structs?, false)
  end
end

unless TestHelper.sorting_on_structs?(),
  do: ExUnit.configure(exclude: :sorting_on_structs)

ExUnit.start()
