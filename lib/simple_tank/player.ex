defmodule SimpleTank.Player do

  defstruct  player_id:     UUID.uuid1(),  
             name:          :"", 
             tank_pid:      :"",
             game_pid:      :game,
             websocket_pid: :""
  
end


