defmodule Everlearn.Mixfile do
  use Mix.Project

  def project do
    [
      app: :everlearn,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Everlearn.Application, []},
      extra_applications: [:logger, :runtime_tools, :timex, :xlsxir]
      # , :ueberauth, :ueberauth_google
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.0", override: true},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:phoenix_haml, "~> 0.2"},
      {:font_awesome_phoenix, "~> 0.1"},
      {:csv, "~> 2.0.0"},          # Converts csvs
      {:ueberauth, "~> 0.4"},
      {:ueberauth_google, "~> 0.5"},
      {:guardian, "~> 1.0-beta"},
      {:timex, "~> 3.1"},
      {:drab, "~> 0.7"},
      {:rummage_phoenix, "~> 1.2.0"}, # Pls dont get further than 1.0.0 !
      {:poison, "~> 3.1"},
      {:phoenix_gon, "~> 0.3.2"},
      {:cors_plug, "~> 1.5", only: :dev},
      {:xlsxir, "~> 1.6.2"},
      {:elixlsx, "~> 0.4.0"},
      {:distillery, "~> 1.5", runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
