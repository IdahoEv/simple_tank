defmodule SimpleTank.Game do
  use GenServer

  @my_pid :game

  @world_update_interval 20   # update physics & game state 50 Hz
  @client_update_interval 100 # send updates to client 10 Hz
  
  defstruct  players: %{},  # map keyed by player_id
             last_updated: SimpleTank.Time.now,
             bullet_list: [] 


  def start_link() do
    IO.puts "registering game server"
    GenServer.start_link __MODULE__, 
      %SimpleTank.Game{},
      name: @my_pid
  end

             
  #Public API
  
  # Make a new tank and associate a player connection to it.
  # Returns
  #   { :ok, <Player> }
  def add_player(_pid, name, websocket_pid) do
    GenServer.call @my_pid, { :add_player, { name, websocket_pid } } 
  end

  # Connect a player and new websocket to his existing tank
  # Player_args should be a tuple like
  #   { <player_id>, <websocket_pid> }
  # Returns one of
  #   { :ok, <Player> }
  #   { :not_found }
  def reconnect_player(_pid, player_id, websocket_pid) do
    GenServer.call @my_pid, { :reconnect_player, { player_id, websocket_pid} } 
  end

  def add_bullet(firing_tank) do
    GenServer.cast @my_pid, { :add_bullet, firing_tank }
  end



  #Server Callbacks
  
  # add_player is a call so that down the road the game can refuse - either because
  # it's too late, or there are too many players, or the game is over.
  #
  # For now, just push a new player onto the state
  def init(_args) do
    IO.puts "Game init called with #{inspect(_args)}"
    { :ok,  %SimpleTank.Tank{} }
  end

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
      # connect as a new player?
      nil -> { :reply, { :not_found }, state }
      player -> 
        player = %SimpleTank.Player{ player | websocket_pid: websocket_pid }
        { :reply,
          { :ok, player },
          %{ state | players: Dict.put(state.players, player.player_id, player) }
        }      
    end
  end
  def handle_call(msg, _from, state) do
    { :stop, "Unhandled call in Game: #{inspect(msg)}", state }
  end

  def handle_cast( {:add_bullet, firing_tank}, state ) do    
    { :noreply, 
      %{ state | bullet_list: 
                 SimpleTank.BulletList.add_bullet(
                    state.bullet_list, 
                    firing_tank.physics.position, 
                    firing_tank.physics.rotation)
       } 
    }
  end

  def handle_cast(msg, state) do
    { :stop, "Unhandled cast in Game: #{inspect(msg)}", state }
  end


  # The main physics / world state update loop.  This is finer-grained than
  # the updates sent to the client, to help keep the physics smooth. The client
  # is expected to interpolate and tween on its own
  def handle_info( :update_world, state) do
    # TODO: compute elapsed time once
    
    # queue up another update a few milliseconds from now
    Process.send_after(self(), :update_world, @world_update_interval)
    bullet_list = SimpleTank.BulletList.update(state.bullet_list)    

    # TODO: tell every tank to update? or let tanks self-update?    
    
    { :noreply, %{ state | bullet_list: bullet_list}}
  end

  # 
  def handle_info(:update_clients, state) do
    Process.send_after(self(), :update_clients, @client_update_interval)

    # map the player list onto physics state of each tank
    # We get a Dict of player -> tank state 
    tank_states = Enum.map(state.players, fn({_player_id, player}) -> 
      {player, SimpleTank.get_public_state(player.tank_pid)} 
    end)

    public_tank_states = Enum.map(tank_states, fn({player, tank_state}) -> 
      {player.name, tank_state} 
    end)
    
    bullets = state.bullet_list 

    # TODO: only do the JSON conversion of tanks and bullet list once, 
    # for optimization.
    Enum.each(state.players, fn({player_id, player}) ->
      {:ok, json} = JSEX.encode(%{ 
        player_id: player_id,
        player_tank_physics: Dict.get(tank_states, player),             
        bullet_list: bullets,
        tanks: public_tank_states
      })
      player.websocket_id ! { :update, json } 
    end)

    { :noreply, state }
  end

  def handle_info(msg, state) do
    { :stop, "Unhandled info in Game: #{inspect(msg)}", state }
  end
end

