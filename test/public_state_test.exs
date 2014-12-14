
Code.require_file "../test_helper.exs", __ENV__.file

defmodule PublicStateFacts do
  use Amrita.Sweet

  alias SimpleTank.PublicState
  alias SimpleTank.TankPhysics
  alias SimpleTank.Tank
  alias SimpleTank.Player

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
  facts "for bullet" do
    alias SimpleTank.Bullet
    
    fact "should include the proper contents" do
      bullet = %Bullet{ 
            id: "id_1234",
            fired: "aotuteuh",
            last_updated: 1234,
            position: %{ x: 123.4, y: 234.5},
            velocity: %{ x: 0, y: 0},
            speed: 8.0,
            rotation: 1.75
      }
      
      { id, state } = PublicState.for_bullet(bullet)
      state |> !equals nil 

      # things the bullet state should have
      id              |> equals "id_1234"
      state.position  |> equals %{ x: 123.4, y: 234.5 }
      state.rotation  |> equals 1.75
      state.speed     |> equals 8.0
      state.angular_velocity |> equals 0.0  # fixed by API
      
      # things the public state shouldn't have
      Dict.get(state, :public_id) |> equals nil
      Dict.get(state, :name)      |> equals nil
      Dict.get(state, :fired)     |> equals nil
      Dict.get(state, :velocity)  |> equals nil
    end    
  end
end


