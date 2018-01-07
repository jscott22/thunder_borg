defmodule ThunderBorg.Application do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    children = [
      {ThunderBorg.I2C, []},
      {ThunderBorg, []}
    ]
    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ThunderBorg.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
