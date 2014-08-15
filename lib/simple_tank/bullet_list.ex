defmodule SimpleTank.BulletList do
  use GenServer

  @update_interval 1000
  
  def start_link() do
    GenServer.start_link __MODULE__, [], name: :bullet_list
  end
  def add_bullet(position, angle) do
    IO.puts "ADDING BULLET"
    GenServer.cast(:bullet_list, { :add_bullet, SimpleTank.Bullet.new(position, angle) })
  end
  def get(pid) do
    GenServer.call(pid, :get )
  end
  def update(pid) do
    GenServer.cast(pid, :update)
  end

  def init( bullet_list ) do
    Dbg.trace(self, :messages)
    SimpleTank.BulletList.update(self)
    { :ok, bullet_list }
  end

  def handle_cast({ :add_bullet, bullet}, bullet_list  ) do
    { :noreply, [ bullet | bullet_list ] }
  end

  def handle_cast(:update, bullet_list) do
    new_list = Enum.map(bullet_list, fn(bul) -> SimpleTank.Bullet.update(bul) end)
    IO.puts "Bullet list: #{inspect(bullet_list)}"
    :erlang.send_after(@update_interval, self, { :"$gen_cast", :update } )
    { :noreply, new_list }
  end

  def handle_call(:get, bullet_list) do
    { :reply, bullet_list, bullet_list }
  end

end

