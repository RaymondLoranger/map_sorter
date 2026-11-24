defmodule MapSorter.Log do
  use File.Only.Logger

  debug :doctest_id, {id, env} do
    """
    \nDoctest ID...
    • ID: #{inspect(id)}
    #{from(env, __MODULE__)}\
    """
  end

  debug :sort_specs, {sort_specs, specs, env, caller} do
    """
    \nSort specs...
    • 'Received' sort specs AST: #{inspect(sort_specs) |> maybe_break(29)}
    • 'Adjusted' sort specs AST: #{inspect(specs) |> maybe_break(29)}
    • Sort specs: #{Macro.to_string(specs) |> maybe_break(14)}
    • Macro: #{fun(env)}
    #{from(caller, __MODULE__)}\
    """
  end

  warning :invalid_specs, {bad_specs, env} do
    """
    \nSort 'declined' given invalid sort specs...
    • 'Invalid' sort specs AST: #{inspect(bad_specs) |> maybe_break(28)}
    • 'Invalid' sort specs: #{Macro.to_string(bad_specs) |> maybe_break(24)}
    • Macro: #{fun(env)}
    #{from(env, __MODULE__)}\
    """
  end

  debug :heredoc_comp_fun_ast, {sort_specs, ast, env} do
    """
    \nAST of #{execution_phase(4)} heredoc compare function...
    • Sort specs AST: #{inspect(sort_specs) |> maybe_break(18)}
    • Sort specs: #{Macro.to_string(sort_specs) |> maybe_break(14)}
    • Compare function AST:
      #{inspect(ast, limit: :infinity)}
    • Compare function:
      #{Macro.to_string(ast) |> String.replace_trailing("end", "\s\send")}
    #{from(env, __MODULE__)}\
    """
  end

  debug :runtime_comp_fun_call_ast, {sort_specs, ast, env} do
    """
    \nAST of 'runtime' compare function call...
    • Sort specs AST: #{inspect(sort_specs) |> maybe_break(18)}
    • Sort specs: #{Macro.to_string(sort_specs) |> maybe_break(14)}
    • Compare function AST:
      #{inspect(ast, limit: :infinity)}
    • Compare function: #{Macro.to_string(ast) |> maybe_break(20)}
    #{from(env, __MODULE__)}\
    """
  end

  debug :runtime_comp_fun_call_heredoc, {sort_specs, heredoc, env} do
    """
    \nHeredoc of 'runtime' compare function call...
    • Sort specs: #{inspect(sort_specs) |> maybe_break(14)}
    • Heredoc:
      #{String.trim_trailing(heredoc) |> String.replace("\n", "\n  ")}
    #{from(env, __MODULE__)}\
    """
  end

  warning :no_runtime_reordering, {sort_specs, env} do
    """
    \nNo 'runtime' reordering will occur as sort specs not a list...
    • Sort specs: #{inspect(sort_specs) |> maybe_break(14)}
    #{from(env, __MODULE__)}\
    """
  end

  ## Private functions

  @spec execution_phase(non_neg_integer) :: String.t()
  defp execution_phase(depth) do
    {_, stacktrace} = Process.info(self(), :current_stacktrace)

    case Enum.at(stacktrace, depth) do
      # If macro `MapSorter.sort/2` is a prior caller, this is compile time...
      {MapSorter, :"MACRO-sort", _, _} -> "'compile time'"
      # Otherwise this is runtime...
      _ -> "'runtime'"
    end
  end
end
