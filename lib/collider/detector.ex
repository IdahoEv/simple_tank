defmodule Collider.Detector do
  
  def collision?({ :circle, c1}, { :circle, c2 }) do 
    maxdist = c1.radius + c2.radius
    dx = c1.position.x - c2.position.x 
    dy = c1.position.y - c2.position.y
    dist = :math.sqrt( dx * dx + dy * dy )
    cond do 
      dist <= maxdist ->
        # TODO: return the vector of the collision as the 2nd argument
        { :collision, nil }
      true ->
        { :no_collision, nil }  
    end
  end
end
