defmodule Mix.Tasks.Cln do
  @moduledoc false

  use Mix.Task

  @spec run(OptionParser.argv) :: :ok
  def run(_args) do
    Mix.Tasks.Cmd.run ~w/mix clean/
    Mix.Tasks.Cmd.run ~w/mix deps.clean --all/
    Mix.Tasks.Cmd.run ~w/mix deps.get/
    Mix.Tasks.Cmd.run ~w/mix dialyzer/
    Mix.Tasks.Cmd.run ~w/mix hex.outdated/
  end
end
