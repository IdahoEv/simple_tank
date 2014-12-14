
Code.require_file "../test_helper.exs", __ENV__.file

defmodule PublicStateFacts do
  use Amrita.Sweet

  alias SimpleTank.PublicState
  alias SimpleTank.TankPhysics
  alias SimpleTank.Tank
  alias SimpleTank.Player

  facts "for player/tank" do
    
    fact "should include the proper contents" do
      tphys = %TankPhysics{
            position: %{ x: 5.5, y: 4.5},
            rotation: 1.75, #:math.pi / -2.0,
            speed: 2.0,
            angular_velocity: 1.5
      }
      tank = %Tank{
        physics: tphys
      }
      player = %Player{
        player_id:     "player_id_1",  
        public_id:     "public_id_1",
        name:          "player_name_1", 
        tank_pid:      "tank_pid_1",
        websocket_pid: "websocket_pid_1"
      }
      provided [ SimpleTank.Tank.get_state(_) |> tank ] do
        state = PublicState.for_tank(player)
        state |> !equals nil 

        # thinks
        state.public_id |> equals "public_id_1"
        state.name      |> equals "player_name_1"
        state.position  |> equals %{ x: 5.5, y: 4.5 }
        state.rotation  |> equals 1.75
        state.speed     |> equals 2.0
        state.angular_velocity |> equals 1.5
        
        # things the public state shouldn't have
        Dict.get(state, :player_id) |> equals nil
        Dict.get(state, :velocity)  |> equals nil
        Dict.get(state, :tank_pid)  |> equals nil
        Dict.get(state, :game_pid)  |> equals nil
        Dict.get(state, :websocket_pid)  |> equals nil
      end 
    end    
  end
end


