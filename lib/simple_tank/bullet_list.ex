defmodule SimpleTank.BulletList do
  use GenServer

  @update_interval 20
  
  def start_link() do
    GenServer.start_link __MODULE__, [], name: :bullet_list
  end
  def add_bullet(pid, position, angle) do
    GenServer.cast( :add_bullet, %{ position: position, angle: angle})
  end
  def get(pid) do
    GenServer.call( :get )
  end
  def update(pid) do
    GenServer.cast(:update)
  end

  

  def handle_cast({ :add_bullet, bullet}, bullet_list  ) do
    { :noreply, [ bullet | bullet_list ] }
  end

  def handle_cast(:update, bullet_list) do
    new_list = Enum.reduce(bullet_list, [], fn(bul) -> SimpleTank.Bullet.update(bul) end)
    IO.puts "Bullet list: #{inspect(bullet_list)}"
    :erlang.send_after(@update_interval, self, { :"$gen_cast", :update } )
    { :noreply, new_list }
  end

  def handle_call(:get, bullet_list) do
    { :reply, bullet_list, bullet_list }
  end

end

