app = Mix.Project.config[:app]
structs_enabled? = Application.get_env(app, :structs_enabled?)
unless structs_enabled?, do: ExUnit.configure(exclude: :sorting_on_structs)
ExUnit.start()
