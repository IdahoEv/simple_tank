defmodule SimpleTank.TankPhysics do
  defstruct last_updated: SimpleTank.Time.now,
            position: %{ x: 0, y: 0},
            rotation: 0.0, #:math.pi / -2.0,
            speed: 0.0,
            angular_velocity: 0.0

  @forward_acceleration 1.75
  @forward_braking 3.0
  @max_forward_speed 4.0

  @reverse_acceleration 0.75
  @reverse_braking 3.0
  @max_reverse_speed -2.0

  # fraction of the speed lost per second at coast
  @coasting_decel_rate 0.75
  @minimum_speed 0.30

  # radians per second
  @rotation_speed 2.0
  @pi :math.pi
  @npi (:math.pi * -1)
  @tau (:math.pi * 2)  

  def update(physics, control_state ) do
    { delta, now } = SimpleTank.Time.delta( physics.last_updated)
    speed = apply_acceleration(physics.speed, control_state.acceleration, delta)
    { rotation, angular_velocity } = apply_rotation(physics.rotation, control_state.rotation, delta)
    #IO.puts "rotation state: #{control_state.rotation.state} old: #{physics.rotation} new: #{rotation}"
    vel = velocity(rotation, speed)
    px = vel.x * delta + physics.position.x
    py = vel.y * delta + physics.position.y
    new_physics = %{ physics | last_updated: now,
                               position: %{ x: px, y: py },
                               rotation: rotation,
                               angular_velocity: angular_velocity,
                               speed: speed
    }
    #IO.puts("(TP upd) #{inspect(%{speed: physics.speed, delta: delta, vel: vel})}")
    #IO.puts("(TP upd) #{inspect(self)} New Physics: #{inspect(new_physics)}")
    #IO.puts("Rot: #{rotation} (#{px}, #{py}) (#{vel.x}, #{vel.y}) ")
    new_physics
  end

  def velocity(rotation, speed) do
    %{ x: :math.cos(rotation) * speed,
       y: :math.sin(rotation) * speed  
    }    
  end  

  def apply_rotation(angle, :left, delta)  do
    { clamp(angle - (delta * @rotation_speed)),
      @rotation_speed 
    }
  end
  def apply_rotation(angle, :right, delta) do
    { clamp(angle + (delta * @rotation_speed)),
      @rotation_speed * -1
    }
  end
  def apply_rotation(angle, :off, _), do: { angle, 0.0 }

  def clamp(angle) when angle > @pi,  do: angle - @tau
  def clamp(angle) when angle < @npi, do: angle + @tau
  def clamp(angle),                   do: angle
  
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
  def apply_acceleration(a, b, c) do
    IO.puts "Unhandled accel call"
    IO.puts "A: #{inspect(a)}"
    IO.puts "B: #{inspect(b)}"
    IO.puts "C: #{inspect(c)}"
    raise "Unhandled accel call"
    System.halt
  end
 
  # TODO: change this to a rectangle
  def geometry(tank_physics) do
    { :circle, %{ position: tank_physics.position, radius: 0.5} }
  end

  
end  
