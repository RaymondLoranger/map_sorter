defmodule MapSorter.Log do
  use File.Only.Logger

  debug :sort_specs, {sort_specs, specs, env, caller} do
    """
    \nSort specs...
    • Inside function:
      #{fun(caller)}
    • Inside macro:
      #{fun(env)}
    • 'Received' sort specs:
      #{inspect(sort_specs)}
    • 'Adjusted' sort specs:
      #{inspect(specs)}
    #{from()}
    """
  end

  error :invalid_specs, {bad_specs, env, caller} do
    """
    \nSort 'declined' given invalid sort specs...
    • Inside function:
      #{fun(caller)}
    • Inside macro:
      #{fun(env)}
    • 'Invalid' sort specs:
      #{inspect(bad_specs)}
    #{from()}
    """
  end

  debug :compile_time_comp_fun_ast, {sort_specs, ast, env} do
    """
    \nAST of 'compile time' compare function...
    • Inside function:
      #{fun(env)}
    • Sort specs:
      #{inspect(sort_specs)}
    • AST:
      #{inspect(ast)}
    #{from()}
    """
  end

  debug :runtime_comp_fun_ast, {sort_specs, ast, env} do
    """
    \nAST of 'runtime' compare function...
    • Inside function:
      #{fun(env)}
    • Sort specs:
      #{inspect(sort_specs)}
    • AST:
      #{inspect(ast)}
    #{from()}
    """
  end

  debug :comp_fun_heredoc, {sort_specs, heredoc, env} do
    """
    \nHeredoc of compare function...
    • Inside function:
      #{fun(env)}
    • Sort specs:
      #{inspect(sort_specs)}
    • Heredoc:
      #{heredoc |> String.trim_trailing() |> String.replace("\n", "\n  ")}
    #{from()}
    """
  end

  debug :generating_compile_time_comp_fun, {sort_specs, env} do
    """
    \nGenerating 'compile time' compare function...
    • Inside function:
      #{fun(env)}
    • Sort specs:
      #{inspect(sort_specs)}
    #{from()}
    """
  end

  debug :generating_runtime_comp_fun, {sort_specs, env} do
    """
    \nGenerating 'runtime' compare function...
    • Inside function:
      #{fun(env)}
    • Sort specs:
      #{inspect(sort_specs)}
    #{from()}
    """
  end

  error :generating_no_op_sort, {sort_specs, env} do
    """
    \nGenerating 'no-op sort' as sort specs not a list...
    • Inside function:
      #{fun(env)}
    • Sort specs:
      #{inspect(sort_specs)}
    #{from()}
    """
  end

  error :sort_specs_cannot_be, {sort_specs, what, env} do
    """
    \nSort specs cannot be #{what}...
    • Inside function:
      #{fun(env)}
    • 'Invalid' sort specs:
      #{inspect(sort_specs)}
    #{from()}
    """
  end
end
