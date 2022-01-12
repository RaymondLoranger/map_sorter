defmodule MapSorter.Log do
  use File.Only.Logger

  debug :sort_specs, {sort_specs, specs, env, caller} do
    """
    \nSort specs...
    • 'Received' sort specs: #{inspect(sort_specs) |> maybe_break(25)}
    • 'Adjusted' sort specs: #{inspect(specs) |> maybe_break(25)}
    #{from(caller, __MODULE__)}
    • Macro: #{fun(env)}
    """
  end

  error :invalid_specs, {bad_specs, env, caller} do
    """
    \nSort 'declined' given invalid sort specs...
    • 'Invalid' sort specs: #{inspect(bad_specs) |> maybe_break(24)}
    #{from(caller, __MODULE__)}
    • Macro: #{fun(env)}
    """
  end

  debug :compile_time_comp_fun_ast, {sort_specs, ast, env} do
    """
    \nAST of 'compile time' compare function...
    • Sort specs: #{inspect(sort_specs) |> maybe_break(14)}
    • AST: #{inspect(ast) |> maybe_break(7)}
    #{from(env, __MODULE__)}
    """
  end

  debug :runtime_comp_fun_ast, {sort_specs, ast, env} do
    """
    \nAST of 'runtime' compare function...
    • Sort specs: #{inspect(sort_specs) |> maybe_break(14)}
    • AST: #{inspect(ast) |> maybe_break(7)}
    #{from(env, __MODULE__)}
    """
  end

  debug :comp_fun_heredoc, {sort_specs, heredoc, env} do
    """
    \nHeredoc of compare function...
    • Sort specs: #{inspect(sort_specs) |> maybe_break(14)}
    • Heredoc:
      #{String.trim_trailing(heredoc) |> String.replace("\n", "\n  ")}
    #{from(env, __MODULE__)}
    """
  end

  debug :generating_compile_time_comp_fun, {sort_specs, env} do
    """
    \nGenerating 'compile time' compare function...
    • Sort specs: #{inspect(sort_specs) |> maybe_break(14)}
    #{from(env, __MODULE__)}
    """
  end

  debug :generating_runtime_comp_fun, {sort_specs, env} do
    """
    \nGenerating 'runtime' compare function...
    • Sort specs: #{inspect(sort_specs) |> maybe_break(14)}
    #{from(env, __MODULE__)}
    """
  end

  error :generating_no_op_sort, {sort_specs, env} do
    """
    \nGenerating 'no-op sort' as sort specs not a list...
    • Sort specs: #{inspect(sort_specs) |> maybe_break(14)}
    #{from(env, __MODULE__)}
    """
  end

  error :sort_specs_cannot_be, {sort_specs, what, env} do
    """
    \nSort specs cannot be #{what}...
    • 'Invalid' sort specs: #{inspect(sort_specs) |> maybe_break(24)}
    #{from(env, __MODULE__)}
    """
  end
end
