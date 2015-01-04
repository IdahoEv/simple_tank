defmodule SimpleTank.PlayerList do

  def new do
    Map.new
  end

  def store(list, player) do
    Dict.put(list, player.id, player)
  end

  def retrieve(list, { :private_id, private_id }) do
    case Dict.values(list) 
           |> Enum.find(fn(pl) -> pl.private_id == private_id end) do
      nil    -> :not_found
      player -> { :ok, player }      
    end
  end
  
  def retrieve(list, player_id) do
    case Dict.fetch(list, player_id) do
     :error         -> :not_found 
     { :ok, player} -> { :ok, player }      
    end
  end

  
  
end
