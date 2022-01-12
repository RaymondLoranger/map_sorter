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
end

# Disable file logging for tests.
Application.put_env(:file_only_logger, :level, :none, persistent: true)
ExUnit.configure(exclude: TestHelper.excluded_tags())
ExUnit.start()
