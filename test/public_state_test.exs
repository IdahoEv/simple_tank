
Code.require_file "../test_helper.exs", __ENV__.file

defmodule PublicStateFacts do
  use Amrita.Sweet

  alias SimpleTank.PublicState
  alias SimpleTank.TankPhysics
  alias SimpleTank.Tank
  alias SimpleTank.Player
  alias SimpleTank.Bullet

  def fixture_player(nn) do
    player = %Player{
      player_id:     "player_id_#{nn}",  
      public_id:     "public_id_#{nn}",
      name:          "player_name_#{nn}", 
      tank_pid:      "tank_pid_#{nn}",
      websocket_pid: "websocket_pid_#{nn}"
    }
  end
  def fixture_tank(nn) do
    tphys = %TankPhysics{
          position: %{ x: (nn + 0.1), y: (nn + 0.2) },
          rotation: nn + 0.3,
          speed: nn + 0.4,
          angular_velocity: nn + 0.5
    }
    tank = %Tank{ physics: tphys }
  end 


  fact "for tank list" do
    pl1 = fixture_player(1)
    pl2 = fixture_player(2) 

    provided [ SimpleTank.Tank.get_state("tank_pid_1") |> fixture_tank(1),
               SimpleTank.Tank.get_state("tank_pid_2") |> fixture_tank(2)
    ] do
      state = PublicState.tank_list([pl1, pl2])
      state            |> !equals nil
      is_map(state)    |> truthy
      Dict.size(state) |> equals 2
      Dict.keys(state) |> contains("public_id_1")
      Dict.keys(state) |> contains("public_id_2")
      is_map(Dict.get(state, "public_id_1")) |> truthy
      is_map(Dict.get(state, "public_id_2")) |> truthy
      Dict.get(state, "public_id_1").position.x |> equals 1.1
      Dict.get(state, "public_id_2").position.y |> equals 2.2
    end
  end
  
  facts "for player/tank" do
    
    fact "should include the proper contents" do
      player = fixture_player(1)

      provided [ SimpleTank.Tank.get_state(_) |> fixture_tank(1) ] do
        {id , state} = PublicState.for_tank(player)
        state |> !equals nil 

        # things the state should have
        id              |> equals "public_id_1"
        state.name      |> equals "player_name_1"
        state.position  |> equals %{ x: 1.1, y: 1.2 }
        state.rotation  |> equals 1.3
        state.speed     |> equals 1.4
        state.angular_velocity |> equals 1.5
        
        # things the public state shouldn't have
        Dict.get(state, :player_id) |> equals nil
        Dict.get(state, :public_id) |> equals nil  # is renamed just 'id' for API purposes
        Dict.get(state, :velocity)  |> equals nil
        Dict.get(state, :tank_pid)  |> equals nil
        Dict.get(state, :game_pid)  |> equals nil
        Dict.get(state, :websocket_pid)  |> equals nil
      end 
    end    
  end

  
  def fixture_bullet(nn) do
     %Bullet{ 
        id: "bullet_id_#{nn}",
        fired: "fired_at_#{nn}",
        last_updated: 1000000 + nn,
        position: %{ x: (nn + 0.1), y: (nn + 0.2) },
        rotation: nn + 0.3,
        speed: nn + 0.4,
        velocity: %{ x: nn + 0.6, y: nn + 0.7 }
      }
  end

  fact "for bullet list" do
    bl1 = fixture_bullet(1)
    bl2 = fixture_bullet(2) 

    state = PublicState.bullet_list([bl1, bl2])
    state            |> !equals nil
    is_map(state)    |> truthy
    Dict.size(state) |> equals 2
    Dict.keys(state) |> contains("bullet_id_1")
    Dict.keys(state) |> contains("bullet_id_2")
    is_map(Dict.get(state, "bullet_id_1")) |> truthy
    is_map(Dict.get(state, "bullet_id_2")) |> truthy
    Dict.get(state, "bullet_id_1").position.x |> equals 1.1
    Dict.get(state, "bullet_id_2").position.y |> equals 2.2
  end

  facts "for bullet" do
    alias SimpleTank.Bullet
    
    fact "should include the proper contents" do
      bullet = fixture_bullet(1)
      
      { id, state } = PublicState.for_bullet(bullet)
      state |> !equals nil 

      # things the bullet state should have
      id              |> equals "bullet_id_1"
      state.position  |> equals %{ x: 1.1, y: 1.2 }
      state.rotation  |> equals 1.3
      state.speed     |> equals 1.4
      state.angular_velocity |> equals 0.0  # fixed by API
      
      # things the public state shouldn't have
      Dict.get(state, :public_id) |> equals nil
      Dict.get(state, :name)      |> equals nil
      Dict.get(state, :fired)     |> equals nil
      Dict.get(state, :velocity)  |> equals nil
    end    
  end
end


