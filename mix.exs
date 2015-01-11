defmodule SimpleTank.Mixfile do
  use Mix.Project

  def project do
    [app: :simple_tank,
     version: "0.0.1",
     elixir: "~> 1.0.0",
     deps: deps,
     test_coverage: [tool: Coverex.Task]
   ] 
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [ 
      mod: { SimpleTank, []},
      applications: [ :cowboy, :ranch, #:dbg
      ]
    ]
  end

  # Dependencies can be hex.pm packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [ { :cowboy, "~> 1.0.0"  },
      { :jsex, "~> 2.0.0" }, 
      { :uuid, "~> 0.1.5" },
      { :amrita, "~> 0.4", github: "josephwilk/amrita" },
      { :apex, "~> 0.3.2 "},
      { :coverex, "~> 1.0.0", only: :test }

      #{ :dbg, "~> 0.14.3" }
    ]
  end
end
