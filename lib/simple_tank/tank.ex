defmodule SimpleTank.Tank do
  use GenServer

  @update_interval 20

  defstruct  physics: %SimpleTank.TankPhysics{},
             control_state: %SimpleTank.TankControlState{},
             name: :"",
             last_fired: 0


  def start_link( name) do
    IO.puts "registering tank #{inspect name}"
    GenServer.start_link __MODULE__, 
      %SimpleTank.Tank{ 
        name: name
      },
      name: name 
  end

  # Public API
  def update_controls(pid, cmd),  do: GenServer.cast(pid, { :update_controls, cmd })
  def update(pid),                do: GenServer.cast(pid, :update)
  def get_public_state(pid),      do: GenServer.call(pid, :get_public_state)
  def fire(pid) do
    GenServer.cast(pid, :fire)
  end

  def init( tank ) do
    #Dbg.trace(self, :messages)
    SimpleTank.Tank.update(self)
    { :ok, tank }
  end

  # GenServer call and cast handlers
  def handle_call(:get_public_state, _from, tank  ) do
    { :reply, tank.physics, tank }
  end

  def handle_cast({ :update_controls, controls}, tank  ) do
    new_tank = %{ tank | control_state: SimpleTank.TankControlState.update_controls(tank.control_state, controls, self) }   
    { :noreply, new_tank }
  end

  def handle_cast( :fire, tank) do
    SimpleTank.Game.add_bullet(tank)
    { :noreply, %{ tank | last_fired: SimpleTank.Time.now } }
  end

  def handle_cast(:update, tank  ) do
    cs = SimpleTank.TankControlState.update( tank.control_state )
    physics = SimpleTank.TankPhysics.update( tank.physics, cs )

    #IO.puts "(Tank handle_cast) Updating tank: #{inspect(self)}, #{tank.name}"
    new_tank = %{ tank | physics: physics, control_state: cs }
    
 
    { :noreply, new_tank }
  end


  def handle_cast(msg, tank ) do
    IO.puts "Unhandled cast:  #{inspect(msg)}"
    { :noreply, tank }
  end

  #def handle_cast({ :update_position, delta}, tank ) do
    #{ :noreply, %{ tank | position:  %{ 
        #x: tank.position.x + delta.x, 
        #y: tank.position.y + delta.y
      #} 
    #}}  
  #end
end

