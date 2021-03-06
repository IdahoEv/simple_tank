defmodule SimpleTank.PublicState do

  def tank_list(player_list) do

    Enum.into(player_list, %{}, fn(player) ->
      for_tank(player)
    end)
  end

  def bullet_list(bullet_list) do
    Enum.into(bullet_list, %{}, fn(bullet) ->
      for_bullet(bullet)
    end)
  end

  def for_tank(player) do
    tank_state = SimpleTank.Tank.get_state(player.tank_pid)
    { to_string(player.id),
      %{ name:      player.name,
         position:  tank_state.physics.position,
         speed:     tank_state.physics.speed,
         rotation:  tank_state.physics.rotation,
         angular_velocity: tank_state.physics.angular_velocity
       }
    }
  end
  def for_bullet(bullet) do
    { to_string(bullet.id),
      %{  position:  bullet.position,
          speed:     bullet.speed,
          rotation:  bullet.rotation,
          angular_velocity: 0
      }
    }
  end
end
