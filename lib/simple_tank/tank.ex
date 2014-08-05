defmodule SimpleTank.Tank do
  use GenServer

  @update_interval 20

  defstruct physics: %SimpleTank.TankPhysics{},
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

  def accelerate(pid) do
    GenServer.cast pid, :accelerate
  end
  def decelerate(pid) do
    GenServer.cast pid, :decelerate
  end
  def update(pid) do
    GenServer.cast pid, :update
  end
  #def update_position(pid, delta) do
    #GenServer.cast pid, { :update_position, delta }
  #end
  def get_position(pid) do
    GenServer.call pid, :get_position
  end


  def init( tank ) do
    SimpleTank.TankList.add_tank(tank.tank_list_pid, tank.name, self)
    Dbg.trace(self, :messages)
    SimpleTank.Tank.update(self)
    { :ok, tank }
  end

  def handle_call(:get_position, _from, tank  ) do
    { :reply, tank.physics.position, tank }
  end

  def handle_cast(:accelerate, tank  ) do
    new_tank = %{ tank | physics: SimpleTank.TankPhysics.accelerate( tank.physics) } 
    #IO.puts "(Tank) new tank: #{inspect(new_tank)}"
    { :noreply, new_tank }
  end

  def handle_cast(:decelerate, tank  ) do
    new_tank = %{ tank | physics: SimpleTank.TankPhysics.decelerate( tank.physics) } 
    #IO.puts "(Tank) new tank: #{inspect(new_tank)}"
    { :noreply, new_tank }
  end

  def handle_cast(:update, tank  ) do
    #IO.puts "(Tank handle_cast) Updating tank: #{inspect(self)}, #{tank.name}"
    new_tank = %{ tank | physics: SimpleTank.TankPhysics.update( tank.physics) } 
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

