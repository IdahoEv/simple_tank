defmodule WebsocketHandler do
  @behaviour :cowboy_websocket_handler

  def init({_tcp, _http}, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_init(_TransportName, req, _opts) do
    IO.puts "init.  Starting timer"
    :erlang.start_timer(500, self(), [])
    {:ok, req, %{} }
  end

  def websocket_handle({:text, msg}, req, state) do
    {:ok, json} = JSEX.decode(msg)
    handle_message(json, req, state)
  end

  def websocket_handle(_data, req, state) do    
    IO.puts "Warning, unhandled message received over socket"
    {:ok, req, state}
  end
  
  # New player connects.
  def handle_message(%{ "connect" => "new", "name" => player_name }, req, state) do
    { :ok, player } = SimpleTank.Game.add_player(:game, player_name, self())
    #{ :ok, reply } = JSEX.encode(%{ player_id: player.player_id })
    {:reply, player_id_reply(player), req, state }
  end

  # Existing player reconnects.
  def handle_message(%{ "connect" => player_id, "name" => player_name}, req, state ) do
    player = case  SimpleTank.Game.reconnect_player(:game, player_id, self()) do
      { :ok, player } -> 
        player
      { :not_found }  -> 
        { :ok, player } = SimpleTank.Game.add_player(:game, player_name, self() )      
    end
    { :reply, player_id_reply(player), req, %{ state | tank_pid: player.tank_pid }}
  end

  def player_id_reply(player) do
    { :ok, reply } = JSEX.encode(%{ player_id: player.player_id })
    { :text, reply }
  end

  # Handle control message from socket.   Pass it to the tank associated in state.
  def handle_message(%{ "controls" => control_map }, req, state) do
    state.tank_pid |> SimpleTank.Tank.update_controls(control_map) 
    { :ok, req, state }
  end

  def handle_message(message, req, state) do
    IO.puts "unhandled socket message in socket handler:  #{inspect(message)}"
    { :ok, req, state }
  end

  # Send an update of the world state out to the client
  def websocket_info({ :update, msg }, req, state) do 
    {:reply, {:text, msg}, req, state}
  end

  def websocket_info(message, req, state) do
    IO.puts "Unhandled erlang message in socket handler:  #{inspect(message)}"
    {:ok, req, state}
  end
  
  def websocket_terminate(_reason, _req, _state) do
    :ok
  end
end
