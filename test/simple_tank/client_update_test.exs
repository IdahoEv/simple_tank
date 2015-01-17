defmodule ClientUpdateFacts do
  use Amrita.Sweet

  #alias SimpleTank.ClientUpdate
  alias SimpleTank.Tank
  #alias SimpleTank.TankPhysics
  alias SimpleTank.Player

  defmodule Fixture do
    def tank_state(nn) do
      %Tank{ 
        physics: "physics_#{nn}",
        control_state: "control_state_#{}",
        name: "name_#{nn}"
        
      }
    end

    def player(nn) do
      %Player{ id:             "id_#{nn}",
               private_id:     private_id(nn),               
               name:          :"name_#{nn}", 
               tank_pid:      :"tank_pid_#{nn}",
               game_pid:      :game,
               websocket_pid: :"websocket_pid_#{nn}"
             }
    end

    def private_id(nn) do
      "private_id_#{nn}"
    end
  end

  #fact "TODO - test that this module can format tank state appropriately"

end

