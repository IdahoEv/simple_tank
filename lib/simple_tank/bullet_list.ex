defmodule SimpleTank.BulletList do

  def update(bullet_list) do
    Enum.filter_map(bullet_list, 
       fn(bul) -> SimpleTank.Bullet.alive?(bul) end,
       fn(bul) -> SimpleTank.Bullet.update(bul) end
    )
  end
  
  def add_bullet(game_state, firing_tank) do
    bullet = SimpleTank.Bullet.new(
      firing_tank.physics.position, 
      firing_tank.physics.rotation,
      firing_tank.player_id 
    )
    %SimpleTank.Game{ game_state | bullet_list: [ bullet | game_state.bullet_list ] }         
  end

end

