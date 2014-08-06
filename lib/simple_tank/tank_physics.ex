defmodule SimpleTank.TankPhysics do
  defstruct last_updated: SimpleTank.Time.now,
            position: %{ x: 0, y: 0},
            rotation: :math.pi / -2.0,
            speed: 0.0

  @forward_acceleration 1.75
  @forward_braking 2.0
  @max_forward_speed 4.0

  @reverse_acceleration 0.75
  @reverse_braking 2.0
  @max_reverse_speed -2.0

  # fraction of the speed lost per second at coast
  @coasting_decel_rate 0.75
  @minimum_speed 0.30

  # radians per second
  @rotation_speed 2.0
            
  def update(physics, control_state ) do
    { delta, now } = SimpleTank.Time.delta( physics.last_updated)
    speed = apply_acceleration(physics.speed, control_state.acceleration.state, delta)
    rotation = apply_rotation(physics.rotation, control_state.rotation.state, delta)
    #IO.puts "rotation state: #{control_state.rotation.state} old: #{physics.rotation} new: #{rotation}"
    vel = velocity(rotation, speed)
    px = vel.x * delta + physics.position.x
    py = vel.y * delta + physics.position.y
    new_physics = %{ physics | last_updated: now,
                               position: %{ x: px, y: py },
                               rotation: rotation,
                               speed: speed
    }
    #IO.puts("(TP upd) #{inspect(%{speed: physics.speed, delta: delta, vel: vel})}")
    #IO.puts("(TP upd) #{inspect(self)} New Physics: #{inspect(new_physics)}")
    new_physics
  end

  def velocity(rotation, speed) do
    %{ x: :math.cos(rotation) * speed,
       y: :math.sin(rotation) * speed  
    }    
  end  

  def apply_rotation(angle, :left, delta),  do: angle - (delta * @rotation_speed)
  def apply_rotation(angle, :right, delta), do: angle + (delta * @rotation_speed)
  def apply_rotation(angle, :off, _),       do: angle 

  def apply_acceleration(speed, :off, _) when (abs(speed) < @minimum_speed) do 
    0.0
  end
  def apply_acceleration(speed, :off, delta) do 
    speed - (speed * @coasting_decel_rate * delta)
  end
  def apply_acceleration(speed, :forward, delta) when speed >=0 do
    min(speed + delta * @forward_acceleration, @max_forward_speed)
  end
  def apply_acceleration(speed, :forward, delta) when speed < 0 do
    speed + delta * @reverse_braking
  end
  def apply_acceleration(speed, :reverse, delta) when speed <= 0 do
    max(speed - delta * @reverse_acceleration, @max_reverse_speed)
  end
  def apply_acceleration(speed, :reverse, delta) when speed > 0 do
    speed - delta * @forward_braking
  end


  
end  
