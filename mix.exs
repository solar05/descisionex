defmodule Descisionex.MixProject do
  use Mix.Project

  def project do
    [
      app: :descisionex,
      version: "0.1.6",
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

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
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
