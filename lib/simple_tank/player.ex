defmodule SimpleTank.Player do

  defstruct  player_id:     "",  
             name:          :"", 
             tank_pid:      :"",
             game_pid:      :game,
             websocket_pid: :""
  
  def new(name, websocket_pid) do
    %__MODULE__{
      player_id: UUID.uuid1(),
      name: name,
      websocket_pid: websocket_pid
    }
  end    
end


