defmodule SimpleTank.Supervisor do
  use Supervisor

  def start_link(_) do
    result = {:ok, sup} = Supervisor.start_link(__MODULE__, [], name: :supervisor)
    start_workers(sup)
    result
  end

  def start_workers(sup) do
    # TODO: move tank and bullet list into Game state, instead of separate servers
    # TODO 2: proper supervision tree with one for the game and one for the tanks
    { :ok, tank_list } = 
       Supervisor.start_child(sup, worker(SimpleTank.TankList, []))
    { :ok, bullet_list } = 
       Supervisor.start_child(sup, worker(SimpleTank.BulletList, []))

  end

  def init(_) do
    supervise [], strategy: :one_for_one
  end

  def add_tank(sup, number) do
    id_num = :io_lib.format("~3.10.0B", [number]) |> :erlang.list_to_binary
    tank = _tank_spec("tank_" <> id_num, :tank_list)
    { :ok, tank_pid } =  Supervisor.start_child(sup, tank)
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

