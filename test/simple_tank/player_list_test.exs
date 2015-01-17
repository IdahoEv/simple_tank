defmodule PlayerListFacts do
  use Amrita.Sweet

  alias SimpleTank.Player
  alias SimpleTank.PlayerList

  def fixture_player(nn) do
    %Player{
      private_id:    "private_id_#{nn}",  
      id:            "id_#{nn}",
      name:          "player_name_#{nn}", 
      tank_pid:      "tank_pid_#{nn}",
      websocket_pid: "websocket_pid_#{nn}"
    }
  end

  fact "should be able to store and retrieve players by id" do
    
    list = PlayerList.new
    pl1 = fixture_player(1)
    pl2 = fixture_player(2)

    list = PlayerList.store(list, pl1)
    list = PlayerList.store(list, pl2)
    PlayerList.retrieve(list, pl1.id)  |> equals {:ok, ^pl1}
    PlayerList.retrieve(list, pl2.id)  |> equals {:ok, ^pl2}
  end

  fact "should be able to store and retrieve players by private id" do    
    
    list = PlayerList.new
    pl1 = fixture_player(1)
    pl2 = fixture_player(2)

    list = PlayerList.store(list, pl1)
    list = PlayerList.store(list, pl2)
    PlayerList.retrieve(list, {:private_id, pl2.private_id}) |> equals {:ok, ^pl2}
    PlayerList.retrieve(list, {:private_id, pl1.private_id}) |> equals {:ok, ^pl1}
  end

  fact "should return :not_found when asked for a non-stored player" do
    
    list = PlayerList.new
    pl1 = fixture_player(1)
    pl2 = fixture_player(2)
    pl3 = fixture_player(3)

    list = PlayerList.store(list, pl1)
    list = PlayerList.store(list, pl2)
    PlayerList.retrieve(list, {:private_id, pl3.private_id}) |> equals :not_found
    PlayerList.retrieve(list, pl3.id)                        |> equals :not_found 
  end


end

