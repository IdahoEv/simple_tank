defmodule SimpleTank.Supervisor do
  use Supervisor

  @my_pid :supervisor

  def start_link(_) do
    {:ok, _supervisor} = Supervisor.start_link(__MODULE__, [], name: @my_pid)
  end

  def init(_) do
    children = [
      worker(SimpleTank.Game, [])
    ]
    supervise(children, strategy: :one_for_one)
  end

  def add_tank(player) do
    spec = _tank_spec(player)
    IO.puts "Worker spec: #{inspect(spec)}"
    { :ok, _tank_pid } =  Supervisor.start_child(@my_pid, spec)
  end

  defp _tank_spec(player) do
    name = :"tank_#{player.id}"
    { name,
      { SimpleTank.Tank, 
        :start_link,
        [ name, player.id ]
      },
      :permanent,
      5000,
      :worker,
      [ SimpleTank.Tank ]
    } 
  end
end

