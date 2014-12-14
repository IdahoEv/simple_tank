defmodule SimpleTank.PublicState do

  alias SimpleTank.Tank

  def tank_list(player_list) do
    #IO.puts "\ntank_list called, argument is:"
    #Apex.ap player_list

    Enum.into(player_list, %{}, fn(player) -> 
      for_tank(player) 
    end)
  end

  def for_tank(player) do
    tank_state = SimpleTank.Tank.get_state(player.tank_pid)    
    { player.public_id, 
      %{ name:      player.name,
         position:  tank_state.physics.position,
         speed:     tank_state.physics.speed,
         rotation:  tank_state.physics.rotation,
         angular_velocity: tank_state.physics.angular_velocity      
       }
    }
  end
  def for_bullet(bullet) do
    { bullet.id, 
      %{  position:  bullet.position,
          speed:     bullet.speed,
          rotation:  bullet.rotation,
          angular_velocity: 0  
      }
    }
  end
end
