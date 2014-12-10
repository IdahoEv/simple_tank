Code.require_file "../test_helper.exs", __ENV__.file

defmodule TankPhysicsFacts do
  @delta 0.5 

  use Amrita.Sweet

  alias SimpleTank.TankPhysics

  facts "apply_acceleration when controls are off" do    

    fact "when speed is under the minimum it should decelate to zero" do
      TankPhysics.apply_acceleration(0.29, :off, 0.5) |>  equals 0.0 
    end    
    fact "when speed is not under the minimum it should slow down by the decel rate" do
      TankPhysics.apply_acceleration(1.0, :off, 0.5) 
        |>  roughly 1.0 - (1.0 *  0.5 * 0.75) 
    end    
  end

end

