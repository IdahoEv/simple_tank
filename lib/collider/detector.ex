defmodule Collider.Detector do
  
  def collision?({ :circle, c1}, { :circle, c2 }) do 
    maxdist = c1.radius + c2.radius
    dx = c1.position.x - c2.position.x 
    dy = c1.position.y - c2.position.y
    dist = :math.sqrt( dx * dx + dy * dy )
    cond do 
      dist <= maxdist ->
        { :collision, vector_between(c1, c2) }
      true ->
        :no_collision
    end
  end
 
  def vector_between(c1, c2) do
    %{ x: c1.position.x - c2.position.x,
       y: c1.position.y - c2.position.y }
  end
end
