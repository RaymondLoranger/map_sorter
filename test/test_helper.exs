app = Mix.Project.config[:app]
sorting_on_structs? = Application.get_env(app, :sorting_on_structs?)
unless sorting_on_structs?, do: ExUnit.configure(exclude: :sorting_on_structs)
ExUnit.start()
