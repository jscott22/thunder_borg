defmodule ThunderBorg do

  use GenServer

  alias ElixirALE.I2C

  @pwm_max                      255
  @command_get_id               0x99  # Get the board identifier
  @command_set_a_fwd            8     # Set motor A PWM rate in a forwards direction
  @command_set_a_rev            9     # Set motor A PWM rate in a reverse direction
  # @command_get_a                10    # Get motor A direction and PWM rate
  @command_set_b_fwd            11    # Set motor B PWM rate in a forwards direction
  @command_set_b_rev            12    # Set motor B PWM rate in a reverse direction
  @i2c_max_len                  6

  defmodule State do

    @i2c_id_thunderborg 0x15
    @bus_number 1

    defstruct bus_number: @bus_number, i2c_address: @i2c_id_thunderborg, found_chip: false
  end

  def start_link() do
    IO.puts("starting")
    GenServer.start_link(__MODULE__, %State{})
  end

  def init(state) do
    IO.puts("Loading ThunderBorg on bus #{state.bus_number}, address #{state.i2c_address}")
    {:ok, pid} = I2C.start_link("i2c-1", 0x15)
    found_chip = init_borg(pid, state.i2c_address)
    updated_state = %State{state | found_chip: found_chip}
    |> IO.inspect()
    test_motors(pid)
    {:ok, updated_state}
  end

  def test_motors(pid) do
    set_motor_1(pid, -1)
    Process.sleep(500)
    set_motor_1(pid, 0)
    Process.sleep(500)
    set_motor_1(pid, 1)
    Process.sleep(500)
    set_motor_1(pid, 0)
    Process.sleep(500)
    set_motor_2(pid, -1)
    Process.sleep(500)
    set_motor_2(pid, 0)
    Process.sleep(500)
    set_motor_2(pid, 1)
    Process.sleep(500)
    set_motor_2(pid, 0)
  end

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

  def raw_read(pid, command, length, _retry_count \\ 3) do
    :ok = raw_write(pid, command)
    I2C.read(pid, length)
  end

  def raw_write(pid, command, data) do
    IO.inspect(<< command, data >>)
    I2C.write(pid, << command, data >>)
  end

  def raw_write(pid, command) do
    I2C.write(pid, << command >>)
  end

  def set_motor_1(pid, power) when power < 0 do
    IO.puts("Reversing motor 1")
    pwm = -trunc(@pwm_max * power)
    raw_write(pid, @command_set_a_rev, pwm)
  end

  def set_motor_1(pid, power = 0) do
    IO.puts("Stopping motor 1")
    pwm = trunc(@pwm_max * power)
    raw_write(pid, @command_set_a_fwd, pwm)
  end

  def set_motor_1(pid, power) do
    IO.puts("Starting motor 1")
    pwm = trunc(@pwm_max * power)
    raw_write(pid, @command_set_a_fwd, pwm)
  end

  def set_motor_2(pid, power) when power < 0 do
    IO.puts("Reversing motor 2")
    pwm = -trunc(@pwm_max * power)
    raw_write(pid, @command_set_b_rev, pwm)
  end

  def set_motor_2(pid, power = 0) do
    IO.puts("Stopping motor 2")
    pwm = trunc(@pwm_max * power)
    raw_write(pid, @command_set_b_fwd, pwm)
  end

  def set_motor_2(pid, power) do
    IO.puts("Starting motor 2")
    pwm = trunc(@pwm_max * power)
    raw_write(pid, @command_set_b_fwd, pwm)
  end

end