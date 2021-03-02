defmodule Sockethost.Cache do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: :redis)
  end

  def init(_) do
    {:ok, conn} = Redix.start_link("redis://10.0.0.100:30005/1")

    IO.puts("Redis Init")

    {:ok, %{client: conn}}
  end

  def handle_cast({:set, pid, nickname}, state) do
    Redix.command(state[:client], ["SET", "nickname:" <> inspect(pid), nickname])

    {:noreply, state}
  end

  def handle_cast({:del, pid}, state) do
    Redix.command(state[:client], ["DEL", "nickname:" <> inspect(pid)])

    {:noreply, state}
  end

  def handle_call({:get, pid}, _from, state) do
    {_, resp} = Redix.command(state[:client], ["GET", "nickname:" <> inspect(pid)])

    {:reply, resp, state}
  end
end
