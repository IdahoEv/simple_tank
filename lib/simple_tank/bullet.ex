defmodule SimpleTank.Bullet do
  defstruct fired: 0,
            last_updated: 0,
            position: %{ x: 0, y: 0},
            velocity: %{ x: 0, y: 0}

  @speed    15.0  # units/sec
  @lifetime 3.0   # sec

  def new(position, angle) do
    now = SimpleTank.Time.now
    %SimpleTank.Bullet{ 
       fired: now,
       last_updated: now,
       position: position,
       velocity: velocity(angle, @speed)
    }
  end

  def update(nil), do: nil
  def update(bullet ) do
    { age, now } = SimpleTank.Time.delta( bullet.fired )
    if (age > @lifetime) do
      nil
    else
      { delta, now } = SimpleTank.Time.delta( now, bullet.last_updated)

      px = bullet.velocity.x * delta + bullet.position.x
      py = bullet.velocity.y * delta + bullet.position.y
      new_bullet = %{ bullet | last_updated: now,
                               position: %{ x: px, y: py }
      }
      new_bullet
    end
  end

  def velocity(rotation, speed) do
    %{ x: :math.cos(rotation) * speed,
       y: :math.sin(rotation) * speed  
    }    
  end  
end
