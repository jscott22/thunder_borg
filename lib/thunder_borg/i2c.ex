defmodule ThunderBorg.I2C do

  use GenServer

  @i2c_max_len 6
  @i2c Application.get_env(:thunder_borg, :i2c, nil)

  defmodule State do
    defstruct i2c_address: nil
  end

  ## Client

  def start_link(%{i2c_address: i2c_address}) do
    GenServer.start_link(__MODULE__, %State{i2c_address: i2c_address}, name: __MODULE__)
  end

  def write(commands) do
    GenServer.cast(__MODULE__, {:write, commands})
  end

  def read(commands) do
    GenServer.call(__MODULE__, {:read, commands})
  end

  ## Server

  def init(%{i2c_address: i2c_address}) do
    {:ok, pid} = @i2c.start_link("i2c-1", i2c_address)
    {:ok, %{i2c: pid}}
  end

  def handle_cast({:write, commands}, state) when is_list(commands) do 
    write_commands(commands, state.i2c)
    {:noreply, state}
  end

  def handle_cast({:write, {command, data}}, state) do
    raw_write(state.i2c, {command, data})
    {:noreply, state}
  end

  def handle_cast({:write, command}, state) do
    raw_write(state.i2c, command)
    {:noreply, state}
  end

  def handle_call({:read, command}, _from, state) do
    data = raw_read(state.i2c, command, @i2c_max_len)
    {:reply, data, state}
  end

  defp raw_read(pid, command, length, _retry_count \\ 3) do
    :ok = raw_write(pid, command)
    @i2c.read(pid, length)
  end

  defp raw_write(pid, {command, data}) do
    @i2c.write(pid, << command, data >>)
  end

  defp raw_write(pid, command) do
    @i2c.write(pid, << command >>)
  end

  defp write_commands(commands, i2c) when is_list(commands) do
    Enum.each(commands, &raw_write(i2c, &1))
  end

end