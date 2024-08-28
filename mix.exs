defmodule Appendix.MixProject do
  use Mix.Project

  @version "0.0.5"
  @description "Handful of helpers for plug applications. No frameworks."
  @repo "https://github.com/devpipe/appendix"

  def project do
    [
      app: :appendix,
      version: @version,
      description: @description,
      package: package(),
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      maintainers: ["Wess Cope"],
      links: %{"Github" => @repo}
    }
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
      {:postgrex, "~> 0.18.0"},
      {:jason, "~> 1.4.3"},
      {:plug_cowboy, "~> 2.7.1"},
      {:ecto_sql, "~> 3.11.3"},
      {:mimerl, "~> 1.3.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
