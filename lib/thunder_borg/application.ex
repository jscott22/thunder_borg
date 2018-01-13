defmodule ThunderBorg.Application do
  use Application

  @bus_number 1
  @i2c_address 0x36

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    children = [
      {ThunderBorg.I2C, %{i2c_address: @i2c_address}},
      {ThunderBorg, %{i2c_address: @i2c_address, bus_number: @bus_number}}
    ]
    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ThunderBorg.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
