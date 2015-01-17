defmodule SimpleTank.Tank do
  use GenServer
  alias SimpleTank.TankControlState
  alias SimpleTank.TankPhysics

  @update_interval 20

  defstruct  physics: %TankPhysics{},
             control_state: %TankControlState{},
             name: :"",
             player_id: nil,
             last_fired: 0,
             game_pid: nil


  def start_link(name, player_id, game_pid) do
    IO.puts "registering tank #{inspect(name)}"
    GenServer.start_link __MODULE__, %SimpleTank.Tank{ name: name, player_id: player_id, game_pid: game_pid }
  end

  # Public API
  def update_controls(pid, cmd),  do: GenServer.cast(pid, { :update_controls, cmd })
  def update(pid),                do: GenServer.cast(pid, :update)
  def get_state(pid),             do: GenServer.call(pid, :get_state)
  def receive_hit(pid),           do: GenServer.cast(pid, :receive_hit)
  def fire(pid),                  do: GenServer.cast(pid, :fire)
  
 
  # GenServer Callbacks
  #
  def init( tank ) do
    SimpleTank.Tank.update(self)
    { :ok, tank }
  end

  # GenServer call and cast handlers
  def handle_call(:get_state, _from, tank  ) do
    { :reply, tank, tank }
  end

  def handle_cast({ :update_controls, controls}, tank  ) do
    { :noreply, %{ tank | 
      control_state: TankControlState.update_controls(tank.control_state, controls, self) 
    }}
  end

  def handle_cast( :fire, tank) do
    SimpleTank.Game.add_bullet(tank.game_pid, tank)
    { :noreply, %{ tank | last_fired: SimpleTank.Time.now } }
  end

  def handle_cast(:update, tank  ) do
    cs = TankControlState.update( tank.control_state )
    physics = TankPhysics.update( tank.physics, cs )

    #IO.puts "(Tank handle_cast) Updating tank: #{inspect(self)}, #{tank.name}"
    new_tank = %{ tank | physics: physics, control_state: cs }
    
    # TODO - maybe? Instead of have the tank update itself, send a message from
    # the main game update look. mrrr.... dunno. 
    :erlang.send_after(@update_interval, self, { :"$gen_cast", :update } )
    { :noreply, new_tank }
  end

  def handle_cast(:receive_hit, tank) do
    # TODO --- decrement health 
    { :noreply, tank }
  end

  def handle_cast(msg, tank ) do
    IO.puts "Unhandled cast:  #{inspect(msg)}"
    { :noreply, tank }
  end
end

