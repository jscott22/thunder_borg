defmodule ThunderBorg do

  use GenServer

  alias ThunderBorg.{Detection, I2C, Motors}
  
  defmodule State do

    @i2c_id_thunderborg 0x15
    @bus_number 1

    defstruct bus_number: @bus_number, i2c_address: @i2c_id_thunderborg, found_chip: false
  end

  def start_link(_) do
    IO.puts("starting")
    GenServer.start_link(__MODULE__, %State{}, name: __MODULE__)
  end

  def init(state) do
    IO.puts("Loading ThunderBorg on bus #{state.bus_number}, address #{state.i2c_address}")

    found_chip = init_borg(state.i2c_address)

    {:ok, %State{state | found_chip: found_chip}}
  end

   ### CLIENT

  def drive(degree, speed) do
    IO.puts("Driving")
    GenServer.cast(__MODULE__, {:drive, {degree, speed}})
  end

  def stop() do
    IO.puts("Stopping")
    GenServer.cast(__MODULE__, :stop)
  end

  ### SERVER

  def handle_cast({:drive, {degree, speed}}, state) do
    Motors.drive({degree, speed})
    |> I2C.write()

    {:noreply, state}
  end

  def handle_cast(:stop, state) do

    Motors.stop()
    |> I2C.write()

    {:noreply, state}
  end

  def handle_info(msg, _state) do
    IO.inspect(msg)
  end

  ### INIT

  defp init_borg(i2c_address) do
    Detection.find_borg(i2c_address)
  end

end