Code.require_file "../../test_helper.exs", __ENV__.file

defmodule TankPhysicsFacts do
  @delta 0.5 

  use Amrita.Sweet

  alias SimpleTank.TankPhysics

  def delta, do: 0.5

  facts "apply_acceleration" do
    facts "when controls are off" do    

      fact "when speed is under the minimum it should decelate to zero" do
        TankPhysics.apply_acceleration(0.29, :off, delta) |>  equals 0.0 
      end    
      fact "when speed is not under the minimum it should slow down by the decel rate" do
        TankPhysics.apply_acceleration(0.31, :off, delta) 
          |>  roughly 0.31 - (0.31 *  delta * 0.75) 
      end    
    end
  end
end

