defmodule TankPhysicsTest do
  use ExUnit.Case

  #alias SimpleTank.TankPhysics, as: TP

  test "update with zero velocity does not change state" do
    tp = %SimpleTank.TankPhysics{ position: %{ x: 0, y: 0}, speed: 0.0 }
    assert SimpleTank.TankPhysics.update(tp).position == tp.position 
  end
end

