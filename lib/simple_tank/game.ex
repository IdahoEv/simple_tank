defmodule SimpleTank.Game do
  use GenServer

  @my_pid :game

  @world_update_interval 20   # update physics & game state 50 Hz
  @client_update_interval 100 # update period to client
  
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
  def get_players, do: GenServer.call(@my_pid, :get_players)

  #Server Callbacks
  
  # add_player is a call so that down the road the game can refuse - either because
  # it's too late, or there are too many players, or the game is over.
  #
  # For now, just push a new player onto the state
  def init(_args) do
    IO.puts "Game init called with #{inspect(_args)}"
    Process.send_after(self(), :update_world,   @world_update_interval)
    Process.send_after(self(), :update_clients, @client_update_interval)
    { :ok,  %SimpleTank.Game{} }
  end

  def handle_call({ :add_player, { name, websocket_pid }}, _from, state) do
    #IO.puts("In add player call handler, state is #{inspect(state)}")
    player  = SimpleTank.Player.new(name, websocket_pid)
    {:ok, tank_pid } =  SimpleTank.Supervisor.add_tank(player.player_id)
    player  = %SimpleTank.Player{ player | tank_pid: tank_pid} 

    { :reply,      
      { :ok, player }, 
      %{ state | players: Dict.put(state.players, player.player_id, player) }
    }
  end

  def handle_call({ :reconnect_player, { player_id, websocket_pid}}, _from, state) do
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

  def handle_call(:get_players, _from, state) do
    { :reply, state.players, state}
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
    # TODO: compute elapsed time, use a single delta for all upates
    #IO.puts("Updating world") 
    
    # queue up another update a few milliseconds from now
    Process.send_after(self(), :update_world, @world_update_interval)
    bullet_list = SimpleTank.BulletList.update(state.bullet_list)    

    # TODO: tell every tank to update? or let tanks self-update?    
    
    { :noreply, %{ state | bullet_list: bullet_list}}
  end

  # 
  def handle_info(:update_clients, state) do
    #IO.puts("Updating #{Dict.size(state.players)} clients") 
    Process.send_after(self(), :update_clients, @client_update_interval)

    # map the player list onto physics state of each tank
    # We get a Dict of player -> tank state.  This is keyed by
    # Player struct, which is not public information. This will
    # not be directly returned to any player, but is used to construct
    # the items that will be.    
    tank_states = Enum.into(state.players, %{}, fn({_player_id, player}) -> 
      {player, SimpleTank.Tank.get_public_state(player.tank_pid)} 
    end)

    #IO.puts "Tank states: #{inspect(tank_states)}"

    # This makes the public-safe list of all tank states, keyed by name
    # instead of player.  It's done as a second step so that tank_states
    # can still be used as a fast way of pulling the current player's 
    # private state, without having to fetch it from the Tank server again. 
    public_tank_states = Enum.into(tank_states, %{}, fn({player, tank_state}) -> 
      {player.name, tank_state} 
    end)
    
    bullets = state.bullet_list 

    # TODO: only do the JSON conversion of tanks and bullet list once, 
    # for optimization.
    Enum.each(state.players, fn({player_id, player}) ->
      {:ok, json} = JSEX.encode(%{ state_update: %{ 
        player_id: player_id,
        public_id: player.public_id,
        player_tank: Dict.get(tank_states, player, nil),             
        bullet_list: bullets,
        tanks: public_tank_states
      }})
      send player.websocket_pid, { :update, json } 
    end)

    { :noreply, state }
  end

  def handle_info(msg, state) do
    { :stop, "Unhandled info in Game: #{inspect(msg)}", state }
  end
end

