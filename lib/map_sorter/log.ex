defmodule MapSorter.Log do
  use File.Only.Logger

  debug :sort_specs, {sort_specs, specs, env, caller} do
    """
    \nSort specs...
    • 'Received' sort specs AST: #{inspect(sort_specs) |> maybe_break(29)}
    • 'Adjusted' sort specs AST: #{inspect(specs) |> maybe_break(29)}
    • Sort specs: #{Macro.to_string(specs) |> maybe_break(14)}
    • Macro: #{fun(env)}
    #{from(caller, __MODULE__)}
    """
  end

  warn :invalid_specs, {bad_specs, env, caller} do
    """
    \nSort 'declined' given invalid sort specs...
    • 'Invalid' sort specs AST: #{inspect(bad_specs) |> maybe_break(28)}
    • 'Invalid' sort specs: #{Macro.to_string(bad_specs) |> maybe_break(24)}
    • Macro: #{fun(env)}
    #{from(caller, __MODULE__)}
    """
  end

  debug :compile_time_comp_fun_ast, {sort_specs, ast, env} do
    """
    \nAST of 'compile time' compare function...
    • Sort specs: #{inspect(sort_specs) |> maybe_break(14)}
    • Compare function AST:
      #{inspect(ast)}
    • Compare function:
      #{Macro.to_string(ast) |> String.replace_trailing("end", "\s\send")}
    #{from(env, __MODULE__)}
    """
  end

  debug :runtime_comp_fun_ast, {sort_specs, ast, env} do
    """
    \nAST of 'runtime' compare function...
    • Sort specs AST: #{inspect(sort_specs) |> maybe_break(18)}
    • Sort specs: #{Macro.to_string(sort_specs) |> maybe_break(14)}
    • Compare function AST: #{inspect(ast) |> maybe_break(24)}
    • Compare function: #{Macro.to_string(ast) |> maybe_break(20)}
    #{from(env, __MODULE__)}
    """
  end

  debug :runtime_comp_fun_heredoc, {sort_specs, heredoc, env} do
    """
    \nHeredoc of 'runtime' compare function...
    • Sort specs: #{inspect(sort_specs) |> maybe_break(14)}
    • Heredoc:
      #{String.trim_trailing(heredoc) |> String.replace("\n", "\n  ")}
    #{from(env, __MODULE__)}
    """
  end

  warn :no_reordering, {sort_specs, env} do
    """
    \nNo reordering as sort specs not a list...
    • Sort specs: #{inspect(sort_specs) |> maybe_break(14)}
    #{from(env, __MODULE__)}
    """
  end
end
