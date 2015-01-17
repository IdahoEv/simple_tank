defmodule SimpleTank.Scoreboard do
  defstruct hits: %{} 

  def handle_cast({:hit, source, target}, state_data) do
    { :noreply, %{ state_data | 
        hits: add_hit(state_data.hits, source, target)
      }
    }
  end 

  def add_hit(hits, source, target) do
    hits_for_source = Dict.get(hits, source, %{})
    hits_on_target  = Dict.get(hits_for_source, target, 0)

    Dict.put(
      hits, 
      source, 
      Dict.put(hits_for_source, target, hits_on_target + 1 )
    )
  end
end
