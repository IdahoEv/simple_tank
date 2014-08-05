defmodule SimpleTank.TankPhysics do
  defstruct last_updated: SimpleTank.Time.now,
            position: %{ x: 0, y: 0},
            rotation: 0,
            speed: 0.1

            
  def update(physics) do
    { delta, now } = SimpleTank.Time.delta( physics.last_updated)
    vel = velocity(physics)
    px = vel.x * physics.speed * delta + physics.position.x
    py = vel.y * physics.speed * delta + physics.position.y
    new_physics = %{ physics | last_updated: now,
                               position: %{ x: px, y: py }
    }
    #IO.puts("(TP upd) #{inspect(%{speed: physics.speed, delta: delta, vel: vel})}")
    #IO.puts("(TP upd) #{inspect(self)} New Physics: #{inspect(new_physics)}")
    new_physics
  end

  def velocity(physics) do
    %{ x: :math.cos(physics.rotation) * physics.speed,
       y: :math.sin(physics.rotation) * physics.speed  
    }    
  end  

  def accelerate(physics) do
    new_physics = %{ physics | speed: physics.speed + 0.1 }
    #IO.puts("(TankPhysics acc) #{inspect(self) }New Physics: #{inspect(new_physics)}")
    new_physics
  end
  
  def decelerate(physics) do
    %{ physics | speed: physics.speed + -0.1 }
  end
end  
