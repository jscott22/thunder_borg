defmodule ThunderBorg.I2C do

  use GenServer

  alias ElixirALE.I2C

  @i2c_max_len 6

  ## Client

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def write(commands) do
    GenServer.cast(__MODULE__, {:write, commands})
  end

  def read(commands) do
    GenServer.call(__MODULE__, {:read, commands})
  end

  ## Server

  def init(_state) do
    {:ok, pid} = I2C.start_link("i2c-1", 0x15)
    {:ok, %{i2c: pid}}
  end

  def handle_cast({:write, commands}, state) do 
    write_commands(commands, state.i2c)
    {:noreply, state}
  end

  def handle_call({:read, command}, _from, state) do
    data = raw_read(state.i2c, command, @i2c_max_len)
    {:reply, data, state}
  end

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