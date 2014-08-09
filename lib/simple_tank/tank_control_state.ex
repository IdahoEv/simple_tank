defmodule SimpleTank.TankControlState do

  defstruct acceleration: %{ state: :off, last_message: SimpleTank.Time.now },
            rotation:     %{ state: :off, last_message: SimpleTank.Time.now } 
 
  # If we haven't gotten a message in this long, assume the user is  
  # no longer holding the key down.  Time in seconds.
  @control_decay 1.0  

  def accelerate( cs, "forward" ), do: set_accel(cs,:forward)
  def accelerate( cs, "reverse" ), do: set_accel(cs,:reverse)
  def accelerate( cs, "off" ),     do: set_accel(cs,:off)
  def accelerate( _, msg) do
    raise "Unhandled acceleration command #{msg}"
  end
  def rotate( cs, "left" ),   do: set_rotation(cs,:left)
  def rotate( cs, "right" ),  do: set_rotation(cs,:right)
  def rotate( cs, "off" ),    do: set_rotation(cs,:off)
  def rotate( _, msg) do
    raise "Unhandled rotation command #{msg}"
  end

  def set_accel(cs, atom) do
    %{ cs | acceleration: %{state: atom, last_message: SimpleTank.Time.now}}
  end
  def set_rotation(cs, atom) do
    IO.puts "Rotation command: #{inspect(cs)}"
    %{ cs | rotation: %{state: atom, last_message: SimpleTank.Time.now}}
  end

  
  # periodic update.  This is responsible for turning off active commands if they haven't
  # been reinforced/repeated from the client within the decay time.  
  def update( cs ) do
    now = SimpleTank.Time.now
    %{ cs | 
      acceleration: decay_acceleration( cs.acceleration, cs.acceleration.last_message, now), 
      rotation:     decay_rotation( cs.rotation, cs.rotation.last_message, now), 
    }
  end
  
  # Turn off the accelerator if we haven't received any messages in a while
  def decay_acceleration( _acc, last, now ) when (@control_decay < (now - last)) do
    %{ state: :off, last_message: now} 
  end
  def decay_acceleration(acc, _, _), do: acc
   
  # Center the steering weel if we haven't received any messages in a while
  def decay_rotation(_rot, last, now ) when (@control_decay < (now - last)) do
    %{ state: :off, last_message: now} 
  end
  def decay_rotation(rot, _, _), do: rot

end
