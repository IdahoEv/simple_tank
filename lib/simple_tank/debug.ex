defmodule SimpleTank.Debug do

  def print_player_registry(websocket_pid) do
    players = SimpleTank.Game.get_players
    IO.puts "------------ Player state -----------"    
    IO.puts "-- current websocket: #{inspect(websocket_pid)}" 
    IO.puts "[ Player ID                            | Tank PID      | alv? | Socket PID    | alv? ]"
            #[ 1609a54e-8266-11e4-a66c-3c15c2e5a4be | #PID<0.267.0> | true | #PID<0.265.0> | true ]   
    Enum.each(players, fn({player_id, player}) ->
      IO.puts "[ #{player_id} |" <>
        " #{inspect(player.tank_pid)} |" <>
        " #{alive?(player.tank_pid)} |" <>       
        " #{inspect(player.websocket_pid)} |" <>
        " #{alive?(player.websocket_pid)} ]"
    end)
    IO.puts "-------------------------------------\n"
  end

  def alive?(pid) do
    :erlang.is_process_alive(pid)
  end
  
end
