defmodule ThunderBorg do

  use GenServer

  alias ElixirALE.I2C
  alias ThunderBorg.Motors

  # @pwm_max                      255
  @command_get_id               0x99  # Get the board identifier
  # @command_set_a_fwd            8     # Set motor A PWM rate in a forwards direction
  # @command_set_a_rev            9     # Set motor A PWM rate in a reverse direction
  # @command_set_b_fwd            11    # Set motor B PWM rate in a forwards direction
  # @command_set_b_rev            12    # Set motor B PWM rate in a reverse direction
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
    {:ok, pid} = I2C.start_link("i2c-1", 0x15)

    i2c_pid = pid
    found_chip = init_borg(pid, state.i2c_address)
    updated_state = %State{state | found_chip: found_chip, i2c_pid: i2c_pid}

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

    i2c = state.i2c_pid

    Motors.handle_drive(direction, 1)
    |> write_commands(i2c)

    {:noreply, state}
  end

  def handle_cast(:stop, state) do

    i2c = state.i2c_pid

    Motors.handle_stop()
    |> write_commands(i2c)

    {:noreply, state}
  end

  def handle_info(msg, _state) do
    IO.inspect(msg)
  end

  ### INIT

  def init_borg(pid, i2c_address) do
    find_borg(pid, i2c_address)
  end

  def find_borg(pid, i2c_address) do
    recv = raw_read(pid, @command_get_id, @i2c_max_len)
    |> :binary.bin_to_list()
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

  ##### I2C CONTROLS

  defp raw_read(pid, command, length, _retry_count \\ 3) do
    :ok = raw_write(pid, command)
    I2C.read(pid, length)
  end

  defp raw_write(pid, {command, data}) do
    IO.inspect(<< command, data >>)
    I2C.write(pid, << command, data >>)
  end

  defp raw_write(pid, command) do
    I2C.write(pid, << command >>)
  end

  defp write_commands(commands, i2c) when is_list(commands) do
    Enum.each(commands, &raw_write(i2c, &1))
  end

end