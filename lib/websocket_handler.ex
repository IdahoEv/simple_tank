defmodule WebsocketHandler do
  @behaviour :cowboy_websocket_handler

  def init({tcp, http}, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_init(_TransportName, req, _opts) do
    :erlang.start_timer(1000, self(), "Hello!")          
    {:ok, req, :undefined_state}
  end

  def websocket_handle({:text, msg}, req, state) do
    {:ok, json} = JSON.decode(msg)
    delta = %{ x: HashDict.get(json, "x"), y: HashDict.get(json, "y")}
    IO.puts inspect(delta)
    tank(state) |> SimpleTank.Tank.update_position(delta)
    {:reply, {:text, "Position updated! "}, req, state}
  end

  def websocket_handle(_rata, req, state) do    
    {:ok, req, state}
  end

  def websocket_info({timeout, _ref, msg}, req, state) do
    position = SimpleTank.Tank.get_position(tank(state))
    :erlang.start_timer(1000, self(), inspect(position) )
    {:reply, {:text, msg}, req, state}
  end

  def tank(_state) do
    SimpleTank.TankList.get_tank(:tank_01)
  end

  def websocket_info(_info, req, state) do
    {:ok, req, state}
  end

  def websocket_terminate(_reason, _req, _state) do
    :ok
  end
end
