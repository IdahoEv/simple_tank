defmodule SimpleTank.Player do

  defstruct  player_id:     "",  
             public_id:     "",
             name:          :"", 
             tank_pid:      :"",
             game_pid:      :game,
             websocket_pid: :""
  
  def new(name, websocket_pid) do
    %__MODULE__{
      player_id: UUID.uuid1(),
      public_id: SimpleTank.Time.uniq_nanosec,
      name: name,
      websocket_pid: websocket_pid
    }
  end    
end


