defmodule SimpleTank.PublicState do

  alias SimpleTank.Tank

  def for_tank(player) do
    tank_state = SimpleTank.Tank.get_state(player.tank_pid)    
    %{
      public_id: player.public_id,
      name:      player.name,
      position:  tank_state.physics.position,
      speed:     tank_state.physics.speed,
      rotation:  tank_state.physics.rotation,
      angular_velocity: tank_state.physics.angular_velocity      
    }
  end
end
