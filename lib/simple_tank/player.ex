defmodule SimpleTank.Player do

  defstruct  player_id:     "",  
             name:          :"", 
             tank_pid:      :"",
             game_pid:      :game,
             websocket_pid: :""
  
  def new(name, tank_pid, websocket_pid) do
    %__MODULE__{
      player_id: UUID.uuid1(),
      name: name,
      tank_pid: tank_pid,
      websocket_pid: websocket_pid
    }
  end    
end


