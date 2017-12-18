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
    |> IO.inspect()
    # test_motors(pid)
    {:ok, updated_state}
  end


  ### SERVER

  def handle_cast({:drive, direction}, state) do
    i2c = state.i2c_pid

    IO.puts("Accepted Drive Cast #{direction}")
    IO.inspect(i2c)

    case direction do
      "forward" ->
        set_motor_1(i2c, 1)
        set_motor_2(i2c, 1)
      "backwards" ->
        set_motor_1(i2c, -1)
        set_motor_2(i2c, -1)
      "left" ->
        set_motor_1(i2c, -1)
        set_motor_2(i2c, 1)
      "right" ->
        set_motor_1(i2c, 1)
        set_motor_2(i2c, -1)
    end

    {:noreply, state}
    
  end

  def handle_cast({:stop, direction}, state) do

    i2c = state.i2c_pid

    IO.puts("Accepted Stop Cast #{direction}")
    IO.inspect(i2c)

    set_motor_1(i2c, 0)
    set_motor_2(i2c, 0)

    {:noreply, state}
  end

  def handle_cast(command, state) do
    IO.puts("Unknown Command")
    IO.inspect(command)

    {:noreply, state}
  end

  def handle_info(msg, _state) do
    IO.inspect(msg)
  end

  ### CLIENT

  def handle_drive("forward") do
    IO.puts("Driving Forward i2c")
    GenServer.cast(__MODULE__, {:drive, "forward"})
  end

  def handle_drive("backwards") do
    IO.puts("Driving backwards i2c")
    GenServer.cast(__MODULE__, {:drive, "backwards"})
  end

  def handle_drive("left") do
    IO.puts("Driving left i2c")
    GenServer.cast(__MODULE__, {:drive, "left"})
  end

  def handle_drive("right") do
    IO.puts("Driving right i2c")
    GenServer.cast(__MODULE__, {:drive, "right"})
  end

  def handle_drive(direction) do
    IO.puts("i2c unknown #{direction}")
  end

  def handle_stop("forward") do
    IO.puts("Stopping Forward i2c")
    GenServer.cast(__MODULE__, {:stop, "forward"})
  end

  def handle_stop("backwards") do
    IO.puts("Stopping Forward i2c")
    GenServer.cast(__MODULE__, {:stop, "backwards"})
  end

  def handle_stop("left") do
    IO.puts("Stopping Forward i2c")
    GenServer.cast(__MODULE__, {:stop, "left"})
  end

  def handle_stop("right") do
    IO.puts("Stopping Forward i2c")
    GenServer.cast(__MODULE__, {:stop, "right"})
  end

  def handle_stop(direction) do
    IO.puts("i2c unknown #{direction}")
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

  ##### MOTOR CONTROLS

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

  # def handle_drive(direction) do
  #   IO.puts("Driving #{direction}")
  # end

  # def handle_stop(direction) do
  #   IO.puts("Stopping #{direction}")
  # end


  # def test_motors(pid) do
  #   set_motor_1(pid, -1)
  #   Process.sleep(500)
  #   set_motor_1(pid, 0)
  #   Process.sleep(500)
  #   set_motor_1(pid, 1)
  #   Process.sleep(500)
  #   set_motor_1(pid, 0)
  #   Process.sleep(500)
  #   set_motor_2(pid, -1)
  #   Process.sleep(500)
  #   set_motor_2(pid, 0)
  #   Process.sleep(500)
  #   set_motor_2(pid, 1)
  #   Process.sleep(500)
  #   set_motor_2(pid, 0)
  # end

end