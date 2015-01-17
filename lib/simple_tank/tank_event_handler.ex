defmodule SimpleTank.TankEventHandler do

  use GenEvent

  def handle_event({ :tank_hit, _firer_id, _target_id, target_pid}, _state) do
    SimpleTank.Tank.receive_hit(target_pid)
    { :ok, _state }
  end
  
end
