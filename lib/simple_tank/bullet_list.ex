defmodule SimpleTank.BulletList do

  def update(bullet_list) do
    Enum.filter_map(bullet_list, 
       fn(bul) -> SimpleTank.Bullet.alive?(bul) end,
       fn(bul) -> SimpleTank.Bullet.update(bul) end
    )
  end
  
  def add_bullet(bullet_list, position, angle, player_id) do
    [ SimpleTank.Bullet.new(position, angle, player_id) | bullet_list ]
  end

end

