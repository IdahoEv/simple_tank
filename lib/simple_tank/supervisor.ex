defmodule SimpleTank.Supervisor do
  use Supervisor

  def start_link(_) do
    result = {:ok, sup} = Supervisor.start_link(__MODULE__, [], name: :supervisor)
    start_workers(sup)
    result
  end

  def start_workers(sup) do
    { :ok, tank_list } = 
       Supervisor.start_child(sup, worker(SimpleTank.TankList, []))

    tanks = [ 
      _tank_spec("01", tank_list)
      #_tank_spec("02", tank_list)
    ]
    Enum.each tanks, fn(tank) -> 
      IO.puts "Attempting to start tank:"
      IO.puts inspect(tank)
      IO.puts "With #{inspect sup}"
      { :ok, tank_pid } =  Supervisor.start_child(sup, tank)
    end
  end

  def init(_) do
    supervise [], strategy: :one_for_one
  end

  defp _tank_spec(id_num, tank_list_pid) do
    name = :"tank_#{id_num}"
    { name,
      { SimpleTank.Tank, 
        :start_link,
        [ {name, tank_list_pid} ]
      },
      :permanent,
      5000,
      :worker,
      [ SimpleTank.Tank ]
    }
  end
end

