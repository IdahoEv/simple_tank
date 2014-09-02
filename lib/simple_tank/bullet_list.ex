defmodule SimpleTank.BulletList do
  use GenServer

  @update_interval 20
  
  def start_link() do
    GenServer.start_link __MODULE__, [], name: :bullet_list
  end
  def add_bullet(position, angle) do
    GenServer.cast(:bullet_list, { :add_bullet, SimpleTank.Bullet.new(position, angle) })
  end
  def get(pid) do
    GenServer.call(pid, :get )
  end
  def update(pid) do
    GenServer.cast(pid, :update)
  end

  def init( bullet_list ) do
    #Dbg.trace(self, :messages)
    SimpleTank.BulletList.update(self)
    { :ok, bullet_list }
  end

  def handle_cast({ :add_bullet, bullet}, bullet_list  ) do
    { :noreply, [ bullet | bullet_list ] }
  end

  def handle_cast(:update, bullet_list) do
    new_list = Enum.filter_map(bullet_list, 
       fn(bul) -> SimpleTank.Bullet.alive?(bul) end,
       fn(bul) -> SimpleTank.Bullet.update(bul) end
    )
    :erlang.send_after(@update_interval, self, { :"$gen_cast", :update } )
    { :noreply, new_list }
  end

  def handle_call(:get, _from, bullet_list) do
    { :reply, bullet_list, bullet_list }
  end

end

