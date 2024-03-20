defmodule Core.MixProject do
  use Mix.Project

  def project do
    [
      app: :core,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixirc_paths: elixirc_paths(Mix.env()),
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Core.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:postgrex, "~> 0.17.3"},
      {:ecto, "~> 3.10"},
      {:ecto_sql, "~> 3.10"},
      {:bcrypt_elixir, "~> 3.1"},
      {:google_api_storage, "~> 0.34.0"},
      {:goth, "~> 1.4"},
      {:solid, "~> 0.15.2"},
      {:faker, "~> 0.18.0", only: [:dev, :test]},
      {:mock, "~> 0.3.8"},
      {:excoveralls, "~> 0.18.0", only: :test}
    ]
  end
end
