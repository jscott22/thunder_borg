defmodule ThunderBorg.MixProject do
  use Mix.Project

  def project do
    [
      app: :thunder_borg,
      version: "0.1.0",
      elixir: "~> 1.6-dev",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ThunderBorg.Application, []},
      extra_applications: applications(Mix.env())
    ]
  end

  defp applications(env) when env in [:prod, :dev], do: [:elixir_ale | general_apps()]
  defp applications(_), do: general_apps()

  defp general_apps, do: [:logger]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_ale, "~> 1.0", only: [:prod, :dev]},
      {:dummy_nerves, path: "../dummy_nerves", only: [:host_dev, :test]}
    ]
  end
end
