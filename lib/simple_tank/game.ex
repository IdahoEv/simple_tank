defmodule SimpleTank.Game do
  use GenServer

  @my_pid :game  #TODO support multiple games, eliminate @my_pid

  @world_update_interval 20   # update physics & game state 50 Hz
  @client_update_interval 100 # update period to client
  
  defstruct  players: SimpleTank.PlayerList.new,  # map keyed by id
             last_updated: SimpleTank.Time.now,
             bullet_list: [],
             event_manager_pid: nil 

  alias SimpleTank.PlayerList

  def start_link() do
    IO.puts "registering game server"
    GenServer.start_link __MODULE__, 
      %SimpleTank.Game{},
      name: @my_pid  #TODO support multiple games, eliminate @my_pid
  end

             
  #Public API
  
  # Make a new tank and associate a player connection to it.
  # Returns
  #   { :ok, <Player> }
  def add_player(_pid, name, websocket_pid) do
    #TODO support multiple games, eliminate @my_pid 
    GenServer.call @my_pid, { :add_player, { name, websocket_pid } } 
  end

  # Connect a player and new websocket to his existing tank
  # Player_args should be a tuple like
  #   { <private_id>, <websocket_pid> }
  # Returns one of
  #   { :ok, <Player> }
  #   { :not_found }
  def reconnect_player(_pid, private_id, websocket_pid) do
    #TODO support multiple games, eliminate @my_pid 
    GenServer.call @my_pid, { :reconnect_player, { private_id, websocket_pid} } 
  end

  def add_bullet(game_pid, firing_tank) do
    GenServer.cast game_pid, { :add_bullet, firing_tank }
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
    {:ok, emgr_pid} = GenEvent.start_link()
    GenEvent.add_handler(emgr_pid, SimpleTank.ScoreboardEventHandler, [])
    GenEvent.add_handler(emgr_pid, SimpleTank.TankEventHandler, [])
    { :ok,  %SimpleTank.Game{ event_manager_pid: emgr_pid} }
  end

  def handle_call({ :add_player, { name, websocket_pid }}, _from, state) do
    #IO.puts("In add player call handler, state is #{inspect(state)}")
    player  = SimpleTank.Player.new(name, websocket_pid)
    {:ok, tank_pid } =  SimpleTank.Supervisor.add_tank(player, self())
    player  = %SimpleTank.Player{ player | tank_pid: tank_pid} 

    { :reply,      
      { :ok, player }, 
      %{ state | players: PlayerList.store(state.players, player) }
    }
  end

  def handle_call({ :reconnect_player, { private_id, websocket_pid}}, _from, state) do
    case state.players[private_id] do
      # connect as a new player?
      nil -> { :reply, { :not_found }, state }
      player -> 
        player = %SimpleTank.Player{ player | websocket_pid: websocket_pid }
        { :reply,
          { :ok, player },
          %{ state | players: PlayerList.store(state.players, player) }
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
    { :noreply, SimpleTank.BulletList.add_bullet(state, firing_tank) }
  end  

  def handle_cast(msg, state) do
    { :stop, "Unhandled cast in Game: #{inspect(msg)}", state }
  end


  # The main physics / world state update loop.  This is finer-grained than
  # the updates sent to the client, to help keep the physics smooth. The client
  # is expected to interpolate and tween on its own
  def handle_info( :update_world, state) do
    # queue up another update a few milliseconds from now
    Process.send_after(self(), :update_world, @world_update_interval)
    { :noreply, SimpleTank.GameUpdate.update(state) }
  end

  # Loop that sends game & tank state info to each connected client
  # over their websocket.
  def handle_info(:update_clients, state) do
    Process.send_after(self(), :update_clients, @client_update_interval)
    SimpleTank.ClientUpdate.send(state)
    { :noreply, state }
  end

  def handle_info(msg, state) do
    { :stop, "Unhandled info in Game: #{inspect(msg)}", state }
  end
end

