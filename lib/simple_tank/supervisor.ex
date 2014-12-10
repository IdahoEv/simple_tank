defmodule SimpleTank.Supervisor do
  use Supervisor

  def start_link(_) do
    result = {:ok, sup} = Supervisor.start_link(__MODULE__, [], name: :supervisor)
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

  def add_tank(sup, number) do
    id_num = :io_lib.format("~3.10.0B", [number]) |> :erlang.list_to_binary
    tank = _tank_spec("tank_" <> id_num)
    { :ok, tank_pid } =  Supervisor.start_child(sup, tank)
  end

  defp _tank_spec(id_num) do
    name = :"tank_#{id_num}"
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

