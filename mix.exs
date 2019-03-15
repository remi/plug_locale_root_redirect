defmodule PlugLocaleRootRedirect.Mixfile do
  use Mix.Project

  # Constants
  @version "0.2.0"

  def project do
    [
      app: :plug_locale_root_redirect,
      version: @version,
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      dialyzer: dialyzer(),
      name: "Plug Locale Root Redirect",
      source_url: "https://github.com/remiprev/plug_locale_root_redirect",
      homepage_url: "https://github.com/remiprev/plug_locale_root_redirect",
      description:
        "A Plug that uses PlugBest to map '/' route to a path based on the Accept-Language HTTP header.",
      docs: [
        extras: ["README.md"],
        main: "readme",
        source_ref: "v#{@version}",
        source_url: "https://github.com/remiprev/plug_locale_root_redirect"
      ]
    ]
  end

  def application do
    [applications: [], extra_applications: [:plug]]
  end

  def dialyzer do
    [
      plt_add_apps: [:plug],
      plt_file: ".plts/.local.plt",
      plt_core_path: ".plts",
      paths: ["_build/dev/lib/plug_best/ebin"]
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.0"},
      {:plug_best, "~> 0.2"},
      {:credo, "~> 1.0", only: :dev},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false}
    ]
  end

  defp package do
    %{
      maintainers: ["Rémi Prévost"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/remiprev/plug_locale_root_redirect"
      }
    }
  end
end
