defmodule Webapp.MixProject do
  use Mix.Project

  def project do
    [
      app: :webapp,
      version: "0.1.0",
      vcs_version: vcs_version(),
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      # TODO: Uncomment on real :prod!
      # start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Webapp.Application, []},
      extra_applications: [:logger, :runtime_tools, :con_cache]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.6.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:ecto_sql, "~> 3.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.3", only: :dev},
      {:phoenix_live_view, "~> 0.17.0"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.1"},
      {:phauxth, "~> 2.5.0"},
      {:argon2_elixir, "~> 2.1"},
      {:bamboo, "~> 2.0"},
      {:bamboo_phoenix, "~> 1.0"},
      {:bamboo_smtp, "~> 4.0"},
      {:canary, git: "https://github.com/runhyve/canary.git"},
      {:plug_cowboy, "~> 2.3"},
      {:plug, "~> 1.7"},
      {:excoveralls, "~> 0.10", only: [:dev, :test]},
      {:httpoison, "~> 1.8"},
      {:phoenix_active_link, github: "danhper/phoenix-active-link"},
      {:table_rex, "~> 2.0.0"},
      {:ecto_network, "~> 1.3.0"},
      {:credo, "~> 1.5.0", only: [:dev, :test], runtime: false},
      {:inet_cidr, "~> 1.0.0"},
      {:iptools, "~> 0.0.2"},
      {:con_cache, "~> 1.0"},
      {:bypass, "~> 2.0", only: :test},
      {:sentry, "~> 8.0"},
      {:hackney, "~> 1.8"},
      {:esbuild, "~> 0.2", runtime: Mix.env() == :dev},
      {:dart_sass, "~> 0.3", runtime: Mix.env() == :dev}
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
      "assets.deploy": [
        "esbuild default --minify",
        "sass default --no-source-map --style=compressed"
      ],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  # Combines version with commit hash, environment etc.
  defp vcs_version do
    if Mix.env() == :prod do
      with {:ok, hash} <- File.read(".vcs_version") do
        String.trim(hash)
      else
        {:error, _} -> "prod"
      end
    else
      "dev"
    end
  end
end
