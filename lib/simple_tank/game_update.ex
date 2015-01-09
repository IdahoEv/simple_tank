defmodule SimpleTank.GameUpdate do
  alias SimpleTank.Game

  def update(old_state) do
    # TODO: compute elapsed time, use a single delta for all upates
    #IO.puts("Updating world") 
    alias SimpleTank.TankPhysics
    alias SimpleTank.Bullet
    alias SimpleTank.Tank

    bullet_list = SimpleTank.BulletList.update(old_state.bullet_list) 

    # make lists of bullet & tank geometries
    bullet_geometry_list = Enum.map(bullet_list, 
      fn(bullet) -> { bullet, Bullet.geometry(bullet)}
    end)
    tank_geometry_list = Enum.map(Dict.values(old_state.players), 
      fn(player) -> { player, TankPhysics.geometry(Tank.get_state(player.tank_pid).physics) }
    end)

    # check for collisions
    collisions = Collider.ListCollider.find_hits(bullet_geometry_list, tank_geometry_list)
    hit_bullets = []
    hit_bullets = Enum.filter_map(collisions, 
      fn({bullet, player, _}) -> 
        if bullet.player_id != player.id do
          IO.puts "Hit on #{player.name}!"            
        end
        bullet.player_id != player.id
      end,
      fn({bullet, player, _}) -> 
        bullet
      end
    )    
    # TODO: tell every tank to update? or let tanks self-update?     
    %Game{ old_state | bullet_list: (bullet_list -- hit_bullets)}
  end
  
end
