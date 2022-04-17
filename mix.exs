defmodule Descisionex.MixProject do
  use Mix.Project

  def project do
    [
      app: :descisionex,
      version: "0.1.0",
      elixir: "~> 1.11",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "Descisionex",
      source_url: "https://github.com/solar05/descisionex"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:matrix, "~> 0.3.2"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Library for dealing with descision theory algorithms."
  end

  defp package() do
    [
      name: "descisionex",
      files: ~w(lib mix.exs README* LICENSE* LICENSE* .formatter.exs),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/solar05/descisionex"}
    ]
  end
end
