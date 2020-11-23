import Config

import_config "config_logger.exs"

import_config "persist_app_constants.exs"
import_config "persist_test_selection.exs"

# For testing purposes only...
config :map_sorter,
  env: "#{Mix.env()} ➔ from #{Path.relative_to_cwd(__ENV__.file)}"
