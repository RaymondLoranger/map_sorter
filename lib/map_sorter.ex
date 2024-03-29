defmodule MapSorter do
  @moduledoc """
  Sorts a list of maps per a list of sort specs.

  Also supports:

  - keywords
  - structs implementing the `Access` behaviour
  - nested maps, keywords or structs implementing the `Access` behaviour
  """

  use PersistConfig

  alias __MODULE__.{Log, SortSpecs}

  @default_formatter Logger.default_formatter()
  @logger_env get_app_env(:file_only_logger, :logger, [])

  @doc """
  Sorts `maps` per the given `sort_specs`.

  Examples of sort specs for flat data structures:
  ```
  - implicit: [:dob, :name]
  - mixed:    [:dob, desc: :name]
  - explicit: [asc: :dob, desc: :name]
  ```

  Examples of sort specs with a `Date` key for flat data structures:
  ```
  - implicit: [{:dob, Date}, :name]
  - mixed:    [{:dob, Date}, desc: :name]
  - explicit: [asc: {:dob, Date}, desc: :name]
  ```

  Examples of sort specs for nested data structures:
  ```
  - implicit: [[:birth, :date], :name]
  - mixed   : [[:birth, :date], desc: :name]
  - explicit: [asc: [:birth, :date], desc: :name]
  ```

  Examples of sort specs with a `Date` key for nested data structures:
  ```
  - implicit: [{[:birth, :date], Date}, :name]
  - mixed:    [{[:birth, :date], Date}, desc: :name]
  - explicit: [asc: {[:birth, :date], Date}, desc: :name]
  ```

  ## Examples

      iex> require MapSorter
      iex> people = [
      ...>   %{name: "Mike", likes: "movies" , dob: "1992-04-15"},
      ...>   %{name: "Mary", likes: "travels", dob: "1992-04-15"},
      ...>   %{name: "Bill", likes: "karate" , dob: "1977-08-28"},
      ...>   %{name: "Joe" , likes: "boxing" , dob: "1977-08-28"},
      ...>   %{name: "Jill", likes: "cooking", dob: "1976-09-28"}
      ...> ]
      iex> sort_specs = Tuple.to_list({:dob, {:desc, :likes}})
      iex> sorted_people = %{
      ...>   explicit: MapSorter.sort(people, asc: :dob, desc: :likes),
      ...>   mixed:    MapSorter.sort(people, [:dob, desc: :likes]),
      ...>   runtime:  MapSorter.sort(people, sort_specs)
      ...> }
      iex> sorted_people.explicit == sorted_people.mixed and
      ...> sorted_people.explicit == sorted_people.runtime and
      ...> sorted_people.explicit
      [
        %{name: "Jill", likes: "cooking", dob: "1976-09-28"},
        %{name: "Bill", likes: "karate" , dob: "1977-08-28"},
        %{name: "Joe" , likes: "boxing" , dob: "1977-08-28"},
        %{name: "Mary", likes: "travels", dob: "1992-04-15"},
        %{name: "Mike", likes: "movies" , dob: "1992-04-15"}
      ]
  """
  defmacro sort(maps, sort_specs) do
    # To enforce logger configuration at compile time.
    # Otherwise logger will use default configuration.
    # dbg_handler_config("Before setting/adding logger handlers...", __CALLER__)
    :ok = :logger.set_handler_config(:default, :formatter, @default_formatter)

    for {:handler, id, :logger_std_h, config} <- @logger_env do
      case :logger.add_handler(id, :logger_std_h, config) do
        :ok -> :ok
        {:error, {:already_exist, ^id}} -> :ok
      end
    end

    # dbg_handler_config("After setting/adding logger handlers...", __CALLER__)

    specs =
      case sort_specs do
        specs when is_list(specs) ->
          # [asc: {:dob, {:__aliases__, [line: 7], [:Date]}}] =>
          # [asc: {:dob, Date}]
          {specs, []} = Code.eval_quoted(specs)
          specs

        specs ->
          # In case any module attributes...
          Macro.expand(specs, __CALLER__)
      end

    :ok = Log.debug(:sort_specs, {sort_specs, specs, __ENV__, __CALLER__})

    case SortSpecs.to_quoted(specs) do
      {:ok, fun_ast} ->
        quote do: Enum.sort(unquote(maps), unquote(fun_ast))

      {:error, invalid_specs} ->
        :ok = Log.warning(:invalid_specs, {invalid_specs, __ENV__, __CALLER__})
        maps
    end
  end

  ## Private functions

  # defp get_handler_config(id, color) do
  #   case :logger.get_handler_config(id) do
  #     {:ok, %{config: %{type: :file, file: file}, level: _level}} ->
  #       file

  #     {:ok,
  #      %{
  #        config: %{type: :standard_io},
  #        level: level,
  #        formatter: {Logger.Formatter, %Logger.Formatter{colors: colors}}
  #      }} ->
  #       {id, level, colors[color]}

  #     {:error, {:not_found, ^id} = error} ->
  #       error
  #   end
  # end

  # @sep "==========================================================="
  # @yellow "\e[33m"
  # @light_yellow "\e[93m"
  # @reset "\e[0m"

  # defp dbg_handler_config(msg, env) do
  #   """
  #   #{@yellow}#{@sep}
  #   #{@light_yellow}#{msg}
  #   #{inspect(env.module)}.#{inspect(env.function)}:#{env.line}
  #   #{get_handler_config(:debug_handler, :debug) |> inspect()}
  #   #{get_handler_config(:default, :debug) |> inspect()}
  #   #{@yellow}#{@sep}#{@reset}
  #   """
  #   |> IO.puts()
  # end
end
