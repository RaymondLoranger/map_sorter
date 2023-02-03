defmodule TestHelper do
  use PersistConfig

  @spec doctests(module) :: [Macro.Env.name_arity()]
  def doctests(module) when is_atom(module) do
    get_env(:doctests, %{})[module] || []
  end

  @spec excluded_tags :: [atom]
  def excluded_tags do
    get_env(:excluded_tags, [])
  end

  # Prevents logging at compile time when called after excluded @tag...
  @spec config_level(module) :: :ok | nil
  def config_level(module) when is_atom(module) do
    [tag | _] = Module.get_attribute(module, :tag)
    if tag in excluded_tags(), do: Logger.configure(level: :none)
  end
end

ExUnit.configure(exclude: TestHelper.excluded_tags())
ExUnit.start()
