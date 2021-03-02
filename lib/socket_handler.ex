defmodule Sockethost.SocketHandler do
  @behaviour :cowboy_websocket

  def init(request, _state) do
    state = %{registry_key: request.path}
    IO.puts("[Init] " <> inspect(self()) <> " -> " <> request.host)
    {:cowboy_websocket, request, state}
  end

  def websocket_init(state) do
    Registry.Sockethost
      |> Registry.register(state.registry_key, {})

    IO.puts("[Conn] " <> inspect(self()))

    GenServer.cast(:redis, {:set, self(), inspect(self())})

    nickname = GenServer.call(:redis, {:get, self()})

    response = Poison.encode!(%{
      "op" => 0,
      "d" => %{
        "heartbeat_interval" => 30000,
        "nickname" => nickname
      }
    })

    broadcast_clientlist("/ws/chat")

    IO.puts("[Tx] " <> inspect(self()) <> " " <> response)
    {:reply, {:text, response}, state}
  end

  def websocket_handle({:text, raw_data}, state) do
    IO.puts("[Rx] " <> inspect(self()) <> " " <> raw_data)
    payload = Poison.decode!(raw_data)

    heartbeat_ack = Poison.encode!(%{"op" => 2})

    case payload["op"] do
      1 -> # Send Heartbeat
        IO.puts("[Tx] " <> inspect(self()) <> " " <> heartbeat_ack)
        {:reply, {:text, heartbeat_ack}, state}
      3 -> # Send Message
        response = Poison.encode!(%{
          "op" => 4,
          "d" => %{
            "message" => payload["d"]["message"],
            "sender" => GenServer.call(:redis, {:get, self()})
          }
        })
        IO.puts("[Tx] Broadcast MSG " <> response)
        broadcast_msg(state.registry_key, response)
        {:ok, state}
      6 -> # Set Nickname
        GenServer.cast(:redis, {:set, self(), payload["d"]["nickname"]})
        response = Poison.encode!(%{
          "op" => 7,
          "d" => %{
            "pid" => inspect(self()),
            "nickname" => GenServer.call(:redis, {:get, self()})
          }
        })
        IO.puts("[Tx] Broadcast NICK " <> response)
        broadcast_msg(state.registry_key, response)
        {:ok, state}
      _ -> {:stop, state}
    end
  end

  def websocket_info(info, state) do
    {:reply, {:text, info}, state}
  end

  def terminate(_remote, _close_code, _payload) do
    broadcast_clientlist("/ws/chat")
    IO.puts("[DisConn] " <> inspect(self()))
    :ok
  end

  def broadcast_msg(path, message) do
    Registry.Sockethost
    |> Registry.dispatch(path, fn(entries) ->
      for {pid, _} <- entries do
        Process.send(pid, message, [])
      end
    end)
  end

  def broadcast_clientlist(path) do
    Registry.Sockethost
    |> Registry.dispatch(path, fn(entries) ->
      for {pid, _} <- entries do
        nickname = GenServer.call(:redis, {:get, pid})
        response = Poison.encode!(%{
          "op" => 5,
          "d" => %{
            "client_list" => entries
            |> Enum.map(fn(x) -> %{"pid"=>inspect(List.first(Tuple.to_list(x))),"nickname" => nickname} end)
            |> Enum.to_list
          }
        })
        IO.puts("[Tx] Broadcast CL " <> response)
        Process.send(pid, response, [])
      end
    end)
  end
end
