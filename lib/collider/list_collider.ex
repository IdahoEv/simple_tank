defmodule Collider.ListCollider do

  # find the intersecting pairs between list_1 and list_2 
  #
  # Each item in the list should be a 2-tuple in the form:
  # { <thing>, { :circle, %{ position: %{ x: <num>, y: <num>}, radius: <num> } }
  def find_hits(list_1, list_2) do
    for { item_1, geom_1 } <- list_1,  
        { item_2, geom_2 } <- list_2, 
        vector = hit?(Collider.Detector.collision?(geom_1, geom_2)) do
      { item_1, item_2, vector}
    end
  end

  def hit?({:collision, vector}), do: vector
  def hit?(_),                    do: false
end

