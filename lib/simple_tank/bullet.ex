defmodule SimpleTank.Bullet do
  defstruct last_updated: SimpleTank.Time.now,
            position: %{ x: 0, y: 0},
            velocity: %{ x: 0, y: 0}

  @speed 15.0

  def new(position, angle) do
    %{ last_updated: SimpleTank.Time.now, 
       position: position,
       velocity: velocity(angle, @speed)
    }
  end

  def update(bullet ) do
    { delta, now } = SimpleTank.Time.delta( bullet.last_updated)

    px = bullet.velocity.x * delta + bullet.position.x
    py = bullet.velocity.y * delta + bullet.position.y
    new_bullet = %{ bullet | last_updated: now,
                             position: %{ x: px, y: py }
    }
    #IO.puts("(TP upd) #{inspect(%{speed: physics.speed, delta: delta, vel: vel})}")
    #IO.puts("(TP upd) #{inspect(self)} New Physics: #{inspect(new_physics)}")
    new_bullet
  end

  def velocity(rotation, speed) do
    %{ x: :math.cos(rotation) * speed,
       y: :math.sin(rotation) * speed  
    }    
  end  
end
