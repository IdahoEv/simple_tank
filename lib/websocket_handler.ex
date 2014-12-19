defmodule WebsocketHandler do
  @behaviour :cowboy_websocket_handler

  alias SimpleTank.Player

  def init({_tcp, _http}, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_init(_TransportName, req, _opts) do
    IO.puts "init.  Starting timer"
    :erlang.start_timer(500, self(), [])
    {:ok, req, nil }
  end

  def websocket_handle({:text, msg}, req, state) do
    {:ok, json} = JSEX.decode(msg)
    handle_message(json, req, state)
  end

  def websocket_handle(_data, req, state) do    
    IO.puts "Warning, unhandled message received over socket"
    {:ok, req, state}
  end
 
  # connect requests should come with either "new" or a private_id.
  def handle_message(%{ "connect" => command, "name" => player_name }, req, state) do
    case SimpleTank.PlayerConnection.connect(command, player_name, state) do
      { :error, _ }         -> { :shutdown, req, state}
      { return, new_state } -> { :reply, return, req, new_state }
    end
  end

  def handle_message(%{ "controls" => control_map }, req, %Player{} = player) do
    #IO.puts "Updating #{inspect(player.tank_pid)} with controls #{inspect(control_map)} "
    SimpleTank.Tank.update_controls(player.tank_pid, control_map) 
    { :ok, req, player }
  end
  # Refuse control messages if there's no player for this websocket.  Shut down
  # instead, forcing the user to reconnect.
  def handle_message(%{ "controls" => _control_map }, req, _state) do
    IO.puts "Shutting down websocket - controls came in with state #{inspect(_state)}"
    { :shutdown, req, _state }
  end

  def handle_message(message, req, state) do
    IO.puts "unhandled socket message in socket handler:  #{inspect(message)}"
    { :ok, req, state }
  end

  # Refuse update messages if there's no player for this websocket.  Shut down
  # instead, forcing a reconnect.
  def websocket_info({ :update, _msg }, req, nil ) do 
    { :shutdown, req, nil}
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
