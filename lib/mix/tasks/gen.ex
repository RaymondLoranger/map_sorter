defmodule Mix.Tasks.Gen do
  @moduledoc false

  use Mix.Task

  def run(_args) do
    Mix.Tasks.Cmd.run ~w/mix compile/
    Mix.Tasks.Cmd.run ~w/mix test/
    Mix.Tasks.Cmd.run ~w/mix dialyzer --no-check/
    Mix.Tasks.Cmd.run ~w/mix docs/
  end
end
