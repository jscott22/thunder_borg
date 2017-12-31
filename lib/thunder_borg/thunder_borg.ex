defmodule ThunderBorg do

  use GenServer

  alias ThunderBorg.I2C
  alias ThunderBorg.Motors

  @command_get_id               0x99
  @i2c_max_len                  6

  defmodule State do

    @i2c_id_thunderborg 0x15
    @bus_number 1

    defstruct bus_number: @bus_number, i2c_address: @i2c_id_thunderborg, found_chip: false, i2c_pid: nil
  end

  def start_link() do
    IO.puts("starting")
    GenServer.start_link(__MODULE__, %State{}, name: __MODULE__)
  end

  def init(state) do
    IO.puts("Loading ThunderBorg on bus #{state.bus_number}, address #{state.i2c_address}")

    found_chip = init_borg(state.i2c_address)
    updated_state = %State{state | found_chip: found_chip}

    {:ok, updated_state}
  end

   ### CLIENT

  def drive(direction) do
    IO.puts("Driving")
    GenServer.cast(__MODULE__, {:drive, direction})
  end

  def stop() do
    IO.puts("Stopping")
    GenServer.cast(__MODULE__, :stop)
  end

  ### SERVER

  def handle_cast({:drive, direction}, state) do

    Motors.drive(direction, 1)
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

  def init_borg(i2c_address) do
    find_borg(i2c_address)
  end

  def find_borg(i2c_address) do
    data = I2C.read(@command_get_id)
    recv = :binary.bin_to_list(data)
    handle_found_device(recv, i2c_address, length(recv) == @i2c_max_len)
  end

  def handle_found_device(recv, i2c_address, true) do
    case Enum.at(recv, 1) == i2c_address do
      true ->
        IO.puts("Found ThunderBorg at #{i2c_address}")
        true
      false ->
        IO.puts("Found a device at #{i2c_address}, but it is not a ThunderBorg")
        false
    end
  end

  def handle_found_device(_recv, i2c_address, false) do
    IO.puts("Missing ThunderBorg at #{i2c_address}")
    false
  end

end