defmodule SimpleTank.Game do
  use GenServer

  @my_pid :game

  @world_update_interval 20   # update physics & game state 50 Hz
  @client_update_interval 100 # send updates to client 10 Hz
  
  defstruct  players: %{}  # map keyed by player_id

  def init(_args) do
    { :ok,  %SimpleTank.Tank{} }
  end

  # get player by ID
  #   { :ok, player_id }
  #   { :not_found } 
  #
  # add new player
  # 
  # internal physics update
  #
  # send updates to all players
  


  #Public API
  
  # Make a new tank and associate a player connection to it.
  # Returns
  #   { :ok, <Player> }
  def add_player(_pid, name, websocket_pid) do
    GenServer.call @my_pid, { :add_player, player_args } 
  end

  # Connect a player and new websocket to his existing tank
  # Player_args should be a tuple like
  #   { <player_id>, <websocket_pid> }
  # Returns one of
  #   { :ok, <Player> }
  #   { :not_found }
  def reconnect_player(_pid, player_id, websocket_pid) do
    GenServer.call @my_pid, { :reconnect_player, player_args } 
  end


  #Server Callbacks
  
  # add_player is a call so that down the road the game can refuse - either because
  # it's too late, or there are too many players, or the game is over.
  #
  # For now, just push a new player onto the state
  def handle_call({ :add_player, { name, websocket_pid }, _from, state}) do
    {:ok, tank_pid } =  SimpleTank.Supervisor.add_tank(
      :supervisor, 
      length(state.players) + 1  
    ) # TODO - clean up when I build a better supervision tree

    player   = %SimpleTank.Player{
      name: name,
      tank_pid: tank_pid,
      websocket_pid: websocket_pid
    }
    { :reply,      
      { :ok, player }, 
      %{ state | players: Dict.put(state.players, player.player_id, player) }
    }
  end

  def handle_call({ :reconnect_player, { player_id, websocket_pid}, _from, state}) do
    case state.players[player_id] do
      nil -> { :reply, { :not_found }, state }
      player -> 
        player = %SimpleTank.Player{ player | websocket_pid: websocket_pid }
        { :reply,
          { :ok, player },
          %{ state | players: Dict.put(state.players, player.player_id, player) }
        }      
    end
  end

  def handle_cast(:update_world, state) do
    
    :erlang.send_after(@update_world_interval, self, { :"$gen_cast", :update_world } )
  end  

  def handle_call(msg, from, state) do
    { :stop, "Unhandled call in Game: #{inspect(msg)}", state }
  end
  def handle_cast(msg, state) do
    { :stop, "Unhandled cast in Game: #{inspect(msg)}", state }
  end
  def handle_info(msg, state) do
    { :stop, "Unhandled info in Game: #{inspect(msg)}", state }
  end

  # TODO: new version of this
  def websocket_info({timeout, _ref, msg}, req, state) do
    physics = SimpleTank.Tank.get_public_state(tank_pid(state))
    bullets = SimpleTank.BulletList.get(bullet_list_pid(state))
    {:ok, json} = JSEX.encode(%{ 
      player_tank_physics: physics,
      bullet_list: bullets
    })
    :erlang.start_timer(50, self(), json )
    {:reply, {:text, msg}, req, state}
  end
end

