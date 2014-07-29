defmodule SimpleTank.Tank do
  use GenServer

  defstruct position: %{ x: 0, y: 0},
     name: :"",
     tank_list_pid: 0


  def start_link({ name, tank_list_pid}) do
    IO.puts "registering tank #{inspect name}"
    GenServer.start_link __MODULE__, 
      %SimpleTank.Tank{ 
        position: %{ x: 0, y: 0},
        name: name,
        tank_list_pid: tank_list_pid
      },
      name: name 
  end

  def update_position(pid, delta) do
    GenServer.cast pid, { :update_position, delta }
  end
  def get_position(pid) do
    GenServer.call pid, :get_position
  end


  def init( tank ) do
    SimpleTank.TankList.add_tank(tank.tank_list_pid, tank.name, self)
    { :ok, tank }
  end
  def handle_call(:get_position, _from, tank  ) do
    { :reply, tank.position, tank }
  end
  def handle_cast({ :update_position, delta}, tank ) do
    { :noreply, %{ tank | position:  %{ 
        x: tank.position.x + delta.x, 
        y: tank.position.y + delta.y
      } 
    }}  
  end
end

