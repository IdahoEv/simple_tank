defmodule SimpleTank.Supervisor do
  use Supervisor

  @my_pid :supervisor

  def start_link(_) do
    result = {:ok, sup} = Supervisor.start_link(__MODULE__, [], name: @my_pid)
    result
  end

  #def start_workers(sup) do
    ## TODO: move bullet list into Game state, instead of separate server
    ## TODO 2: proper supervision tree with one for the game and one for the tanks
    #{ :ok, bullet_list } = 
       #Supervisor.start_child(sup, worker(SimpleTank.BulletList, []))
  #end

  def init(_) do
    children = [
      worker(SimpleTank.Game, [])
    ]
    supervise(children, strategy: :one_for_one)
  end

  def add_tank(player_id) do
    spec = _tank_spec(player_id)
    IO.puts "Worker spec: #{inspect(spec)}"
    { :ok, tank_pid } =  Supervisor.start_child(@my_pid, spec)
  end

  defp _tank_spec(player_id) do
    name = :"tank_#{player_id}"
    { name,
      { SimpleTank.Tank, 
        :start_link,
        [ name ]
      },
      :permanent,
      5000,
      :worker,
      [ SimpleTank.Tank ]
    }
  end
end

