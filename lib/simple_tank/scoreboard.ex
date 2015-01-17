defmodule SimpleTank.Scoreboard do
  use GenServer

  # TODO: support a scoreboard for each game, when multiple games happen
  @my_pid SimpleTank.Scoreboard

  defstruct hits: %{} 

  ### Public API
  
  def start_link(args) do
    IO.puts "Scoreboard start_link with args: #{inspect(args)}"
    GenServer.start_link __MODULE__, %SimpleTank.Scoreboard{}, args
  end


  def init(args) do
    IO.puts "Scoreboard init with args: #{inspect(args)}"
    { :ok, args }
  end

  def hit(_pid, source, target) do
    GenServer.cast(@my_pid, {:hit, source, target})
  end



  ### GenServer Callbacks
  
  def handle_cast({:hit, source, target}, state_data) do
    { :noreply, %{ state_data | 
        hits: add_hit(state_data.hits, source, target)
      }
    }
  end 

  ### Private functions

  # Add a hit to the hit matrix.
  defp add_hit(hits, source, target) do
    src_hit_map   = Dict.get(hits, source, %{})
    
    result = Dict.put(
      hits, 
      source, 
      Dict.put(
        src_hit_map, 
        target, 
        Dict.get(src_hit_map, target, 0) + 1 )
    )
    result
  end
end
