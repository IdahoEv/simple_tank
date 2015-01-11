defmodule SimpleTank.GameUpdate do
  alias SimpleTank.Game
  alias SimpleTank.TankPhysics
  alias SimpleTank.Bullet
  alias SimpleTank.Tank

  def update(old_state) do
    # TODO: compute elapsed time, use a single delta for all upates
    #IO.puts("Updating world") 

    bullet_list = SimpleTank.BulletList.update(old_state.bullet_list) 
    tank_map = build_tank_map(old_state) 

    # make lists of bullet & tank geometries
    bullet_geometry_list = get_bullet_geometries(bullet_list) 
    tank_geometry_list = get_tank_geometries(tank_map)

    impacted_bullets = do_bullet_collisions(bullet_geometry_list, tank_geometry_list)

    %Game{ old_state | bullet_list: (bullet_list -- impacted_bullets)}
  end

  def build_tank_map(old_state) do
    Enum.map(Dict.values(old_state.players), 
      fn(player) -> 
        { player, Tank.get_state(player.tank_pid) }
      end
    )
  end

  def get_bullet_geometries(bullet_list) do
    Enum.map(bullet_list, 
    fn(bullet) -> { bullet, Bullet.geometry(bullet)}
    end)
  end

  def get_tank_geometries(tank_map) do
    Enum.map(tank_map, 
    fn({player, tank}) -> { player, TankPhysics.geometry(tank.physics) }
    end)
  end

  def do_bullet_collisions(bullet_geometry_list, tank_geometry_list) do
    collisions = Collider.ListCollider.find_hits(bullet_geometry_list, tank_geometry_list)
    Enum.filter_map(collisions, 
      fn({bullet, player, _}) -> 
        bullet.player_id != player.id
      end,
      fn({bullet, player, _}) -> 
        IO.puts "Hit on #{player.name}!"            
        bullet
      end
    )    
  end
end
