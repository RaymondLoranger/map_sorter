defmodule TestHelper do
  use PersistConfig

  def doctest(module) when is_atom(module) do
    get_env(:doctest, %{})[module] || []
  end

  def excluded_tags do
    get_env(:excluded_tags, [])
  end

  def config_level(module) when is_atom(module) do
    [tag] = Module.get_attribute(module, :tag)
    if tag in excluded_tags(), do: Logger.configure(level: :none)
  end
end

ExUnit.configure(exclude: TestHelper.excluded_tags())
ExUnit.start()
