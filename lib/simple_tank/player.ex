defmodule SimpleTank.Player do

  defstruct  id:            "",  
             private_id:     "",
             name:          :"", 
             tank_pid:      :"",
             game_pid:      :game,
             websocket_pid: :""
  
  def new(name, websocket_pid) do
    %__MODULE__{
      id: SimpleTank.Time.uniq_nanosec,
      private_id: UUID.uuid1(),
      name: name,
      websocket_pid: websocket_pid
    }
  end    
end


