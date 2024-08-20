defmodule Tuid.MixProject do
  use Mix.Project

  def project do
    [
      app: :tuid,
      version: "0.2.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "tuid",
      source_url: "https://github.com/amattn/tuid"
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
      {:ecto, "~> 3.12"},
      {:uniq, "~> 0.6"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Tagged, unique ids.  K-sortable, based on tagged, base58 encoded UUIDv7 IDs"
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "tuid",
      # These are the default files included in the package
      files: ~w(lib test doc .formatter.exs mix.exs README*  LICENSE*
                LICENSE CHANGELOG),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/amattn/tuid"}
    ]
  end
end
