defmodule SimpleTank.Bullet do
  defstruct id: nil,
            player_id: nil,
            fired: 0,
            last_updated: 0,
            position: %{ x: 0, y: 0},
            velocity: %{ x: 0, y: 0},
            speed: 0,
            rotation: 0

  @speed    10.0  # units/sec
  @lifetime 2.0   # sec
  @radius   0.1

  def new(position, rotation, player_id) do
    now = SimpleTank.Time.now
    %SimpleTank.Bullet{ 
       id: SimpleTank.Time.uniq_nanosec,
       player_id: player_id,
       fired: now,
       last_updated: now,
       position: position,
       velocity: velocity(rotation, @speed),
       speed: @speed,
       rotation: rotation
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

  def geometry(bullet) do
    { :circle, %{ position: bullet.position, radius: @radius } }
  end
end
