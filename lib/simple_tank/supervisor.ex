defmodule SimpleTank.Supervisor do
  use Supervisor

  @my_pid :supervisor

  def start_link(_) do
    {:ok, _supervisor} = Supervisor.start_link(__MODULE__, [], name: @my_pid)
  end

  def init(_) do
    children = [
      worker(SimpleTank.Game,       []),
      worker(SimpleTank.Scoreboard, [[name: SimpleTank.Scoreboard]]),
    ]
    supervise(children, strategy: :one_for_one)
  end

  def add_tank(player, game_pid) do
    spec = _tank_spec(player, game_pid)
    IO.puts "Worker spec: #{inspect(spec)}"
    { :ok, _tank_pid } =  Supervisor.start_child(@my_pid, spec)
  end

  defp _tank_spec(player, game_pid) do
    name = :"tank_#{player.id}"
    { name,
      { SimpleTank.Tank, 
        :start_link,
        [ name, player.id, game_pid ]
      },
      :permanent,
      5000,
      :worker,
      [ SimpleTank.Tank ]
    } 
  end
end

