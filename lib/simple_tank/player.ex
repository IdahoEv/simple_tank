defmodule SimpleTank.Player do

  defstruct  player_id:     UUID.uuid1(),  
             name:          :"", 
             tank_pid:      :"",
             game_pid:      :game,
             websocket_pid: :""
              
  # TODO: update websocket
  
  #def new_player_id do
    #UUID.uuid1()
  #end
  
end


