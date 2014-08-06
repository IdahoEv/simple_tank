defmodule SimpleTank.Tank do
  use GenServer

  @update_interval 20

  defstruct  physics: %SimpleTank.TankPhysics{},
             control_state: %SimpleTank.TankControlState{},
             name: :"",
             tank_list_pid: 0


  def start_link({ name, tank_list_pid}) do
    IO.puts "registering tank #{inspect name}"
    GenServer.start_link __MODULE__, 
      %SimpleTank.Tank{ 
        name: name,
        tank_list_pid: tank_list_pid
      },
      name: name 
  end

  def accelerate(pid, command) do
    GenServer.cast pid, { :accelerate, command }
  end
  def rotate(pid, command) do
    GenServer.cast pid, { :rotate, command }
  end
  def update(pid) do
    GenServer.cast pid, :update
  end
  #def update_position(pid, delta) do
    #GenServer.cast pid, { :update_position, delta }
  #end
  def get_public_state(pid) do
    GenServer.call pid, :get_public_state
  end


  def init( tank ) do
    SimpleTank.TankList.add_tank(tank.tank_list_pid, tank.name, self)
    Dbg.trace(self, :messages)
    SimpleTank.Tank.update(self)
    { :ok, tank }
  end

  def handle_call(:get_public_state, _from, tank  ) do
    { :reply, tank.physics, tank }
  end

  def handle_cast({ :accelerate, command}, tank  ) do
    new_tank = %{ tank | control_state: SimpleTank.TankControlState.accelerate(tank.control_state, command) }   
    { :noreply, new_tank }
  end
  def handle_cast({ :rotate, command}, tank  ) do
    new_tank = %{ tank | control_state: SimpleTank.TankControlState.rotate(tank.control_state, command) }   
    { :noreply, new_tank }
  end

  def handle_cast(:update, tank  ) do
    cs = SimpleTank.TankControlState.update( tank.control_state )
    physics = SimpleTank.TankPhysics.update( tank.physics, cs )

    #IO.puts "(Tank handle_cast) Updating tank: #{inspect(self)}, #{tank.name}"
    new_tank = %{ tank | physics: physics, control_state: cs }
  
    :erlang.send_after(@update_interval, self, { :"$gen_cast", :update } )
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

