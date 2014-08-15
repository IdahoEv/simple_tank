defmodule SimpleTank.Bullet do
  defstruct fired: 0,
            last_updated: 0,
            position: %{ x: 0, y: 0},
            velocity: %{ x: 0, y: 0},
            angle: 0

  @speed    10.0  # units/sec
  @lifetime 2.0   # sec

  def new(position, angle) do
    now = SimpleTank.Time.now
    %SimpleTank.Bullet{ 
       fired: now,
       last_updated: now,
       position: position,
       velocity: velocity(angle, @speed),
       angle: angle
    }
  end

  def alive?(bullet) do
    { age, _ } = SimpleTank.Time.delta( bullet.fired )
    if (age > @lifetime) do
      false
    else
      bullet
    end
  end

  def update(nil), do: nil
  def update(bullet ) do
      { delta, now } = SimpleTank.Time.delta( bullet.last_updated)

      px = bullet.velocity.x * delta + bullet.position.x
      py = bullet.velocity.y * delta + bullet.position.y
      new_bullet = %{ bullet | last_updated: now,
                               position: %{ x: px, y: py }
      }
      new_bullet
  end

  def velocity(rotation, speed) do
    %{ x: :math.cos(rotation) * speed,
       y: :math.sin(rotation) * speed  
    }    
  end  
end
