defmodule MapSorter.Log do
  use File.Only.Logger

  debug :sort_specs, {env, caller, sort_specs, specs} do
    """
    \nSort specs...
    • 'Received' sort specs:
      #{inspect(sort_specs)}
    • 'Adjusted' sort specs:
      #{inspect(specs)}
    • Inside macro: #{function(env)}
    • Inside function:
      #{function(caller)}
    #{from()}
    """
  end

  debug :compile_time_comp_fun_ast, {env, sort_specs, ast} do
    """
    \nAST of 'compile time' compare function...
    • Sort specs:
      #{inspect(sort_specs)}
    • AST:
      #{inspect(ast)}
    • Inside function:
      #{function(env)}
    #{from()}
    """
  end

  debug :runtime_comp_fun_ast, {env, sort_specs, ast} do
    """
    \nAST of 'runtime' compare function...
    • Sort specs:
      #{inspect(sort_specs)}
    • AST:
      #{inspect(ast)}
    • Inside function:
      #{function(env)}
    #{from()}
    """
  end

  debug :comp_fun_heredoc, {env, sort_specs, heredoc} do
    """
    \nHeredoc of compare function...
    • Sort specs:
      #{inspect(sort_specs)}
    • Heredoc:
      #{heredoc |> String.trim_trailing() |> String.replace("\n", "\n  ")}
    • Inside function:
      #{function(env)}
    #{from()}
    """
  end

  debug :generating_compile_time_comp_fun, {env, sort_specs} do
    """
    \nGenerating 'compile time' compare function...
    • Sort specs:
      #{inspect(sort_specs)}
    • Inside function:
      #{function(env)}
    #{from()}
    """
  end

  debug :generating_runtime_comp_fun, {env, sort_specs} do
    """
    \nGenerating 'runtime' compare function...
    • Sort specs:
      #{inspect(sort_specs)}
    • Inside function:
      #{function(env)}
    #{from()}
    """
  end

  warn :generating_no_op_sort, {env, sort_specs} do
    """
    \nGenerating 'no-op sort' as sort specs not a list...
    • Sort specs:
      #{inspect(sort_specs)}
    • Inside function:
      #{function(env)}
    #{from()}
    """
  end

  warn :invalid_specs, {env, caller, bad_specs} do
    """
    \nSort 'declined' given invalid sort specs...
    • 'Invalid' sort specs:
      #{inspect(bad_specs)}
    • Inside macro: #{function(env)}
    • Inside function:
      #{function(caller)}
    #{from()}
    """
  end

  warn :sort_specs_cannot_be, {env, sort_specs, what} do
    """
    \nSort specs cannot be #{what}...
    • 'Invalid' sort specs:
      #{inspect(sort_specs)}
    • Inside function:
      #{function(env)}
    #{from()}
    """
  end

  ## Private functions

  @spec function(Macro.Env.t()) :: String.t()
  defp function(%Macro.Env{} = env) do
    case env.function do
      {name, arity} ->
        if name |> Atom.to_string() |> String.contains?(" ") do
          "#{inspect(env.module)}.'#{name}'/#{arity}"
        else
          "#{inspect(env.module)}.#{name}/#{arity}"
        end

      nil ->
        "'not inside a function'"
    end
  end
end
