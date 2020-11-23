import Config

# config :log_reset, levels: :all
# config :file_only_logger, log?: true

# For testing purposes only...
config :map_sorter,
  env: "#{config_env()} ➔ from #{Path.relative_to_cwd(__ENV__.file)}"
