defmodule SimpleTank.TankControlState do

  defstruct last_update: SimpleTank.Time.now, 
            acceleration: :off,
            rotation: :off,
            trigger: :off
 
  # If we haven't gotten a message in this long, assume the user is  
  # no longer holding the key down.  Time in seconds.
  @control_decay 1.0  


  def update_controls(cs, new_commands, tank_pid) do
    new_cs = update_controls(cs, new_commands)
    if (new_cs.trigger == :on and cs.trigger == :off) do
      SimpleTank.Tank.fire(tank_pid)
    end
    new_cs
  end
  defp update_controls(cs, new_commands) do
    # TODO: don't explicitly use to_atom, because it allows DoS attack by sending bad
    # strings. 
    %{ cs | trigger:      String.to_atom(new_commands["trigger"]),      
            acceleration: String.to_atom(new_commands["acceleration"]),
            rotation:     String.to_atom(new_commands["rotation"]),
            last_update: SimpleTank.Time.now
      }
  end
  
  # periodic update.  This is responsible for turning off active commands if they haven't
  # been reinforced/repeated from the client within the decay time.  
  def update( cs ) do
    now = SimpleTank.Time.now
    %{ cs | 
      acceleration: decay_acceleration( cs.acceleration, cs.last_update, now), 
      rotation:     decay_rotation( cs.rotation, cs.last_update, now), 
    }
  end
  
  # Turn off the accelerator if we haven't received any messages in a while
  def decay_acceleration( _acc, last, now ) when (@control_decay < (now - last)) do
    :off  
  end
  def decay_acceleration(acc, _, _), do: acc
   
  # Center the steering weel if we haven't received any messages in a while
  def decay_rotation(_rot, last, now ) when (@control_decay < (now - last)) do
    :off
  end
  def decay_rotation(rot, _, _), do: rot

end
