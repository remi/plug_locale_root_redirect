defmodule PlugLocaleRootRedirect.Mixfile do
  use Mix.Project

  def project do
    [app: :plug_locale_root_redirect,
     version: "0.1.0",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [
      {:plug, " ~> 1.0"},
      {:plug_best, " ~> 0.1"}
    ]
  end
end
