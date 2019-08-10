defmodule CredoContrib.MixProject do
  use Mix.Project

  @github_url "https://github.com/xtian/credo_contrib"
  @version "0.2.0"

  def project do
    [
      app: :credo_contrib,
      version: @version,
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      description: description(),
      package: package(),

      # Docs
      name: "CredoContrib",
      docs: [
        main: "readme",
        extras: ["README.md"],
        source_ref: "v#{@version}",
        source_url: @github_url
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.0"},
      {:ex_doc, "~> 0.18.0", only: :dev}
    ]
  end

  def description do
    """
    A set of community-maintained checks for the Credo static analysis tool.
    Many of the checks are implementations of rules from
    https://github.com/christopheradams/elixir_style_guide.
    """
  end

  def package do
    [
      maintainers: ["Christian Wesselhoeft"],
      licenses: ["ISC"],
      links: %{"GitHub" => @github_url}
    ]
  end
end
