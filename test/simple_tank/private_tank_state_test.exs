
Code.require_file "../../test_helper.exs", __ENV__.file

defmodule PrivateTankStateFacts do
  use Amrita.Sweet

  alias SimpleTank.PrivateTankState
  alias SimpleTank.TankPhysics
  alias SimpleTank.Tank
  alias SimpleTank.Player

  def fixture_player(nn) do
    %Player{
      private_id:    "private_id_#{nn}",  
      id:            "id_#{nn}",
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
    %Tank{ physics: tphys }
  end 

  fact "private tank state" do

    provided [ SimpleTank.Tank.get_state(_) |> fixture_tank(1) ] do
      state = PrivateTankState.for_tank(fixture_player(1))
      state |> !equals nil 

      # things the state should have
      state.id        |> equals "id_1"
      state.name      |> equals "player_name_1"
      state.position  |> equals %{ x: 1.1, y: 1.2 }
      state.rotation  |> equals 1.3
      state.speed     |> equals 1.4
      state.angular_velocity |> equals 1.5
      
      # things the public state shouldn't have
      Dict.get(state, :private_id) |> equals nil
      Dict.get(state, :velocity)  |> equals nil
      Dict.get(state, :tank_pid)  |> equals nil
      Dict.get(state, :game_pid)  |> equals nil
      Dict.get(state, :websocket_pid)  |> equals nil
    end 

  end

end
