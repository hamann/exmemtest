defmodule Exmemtest.Mixfile do
  use Mix.Project

  def project do
    [app: :exmemtest,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: ["lib"],
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {Exmemtest, []},
      applications: 
      [
        :logger,
        :postgrex,
        :ecto,
        :faker,
      ]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:postgrex, "~> 0.8"},
      {:ecto, "~> 0.13"},
      {:faker, "~> 0.5"}
    ]
  end
end
