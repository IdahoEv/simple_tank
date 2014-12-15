
Code.require_file "../../test_helper.exs", __ENV__.file

defmodule ColliderDetectorFacts do
  use Amrita.Sweet

  alias Collider.Detector

  defmodule Fixture do
    def circle(x, y, radius) do
      { :circle, %{ position: %{ x: x, y: y}, radius: radius }  } 
    end
  end

  facts "circle to circle collision" do
    fact "Can detect collisions in the SE quadrant" do
      c1 = Fixture.circle(1.0,1.0,0.5)
      Detector.collision?(c1, Fixture.circle(0.5,0.5,0.5)) |> { :collision, _ } 
      Detector.collision?(c1, Fixture.circle(1.5,1.5,0.5)) |> { :collision, _ } 
      Detector.collision?(c1, Fixture.circle(0.5,1.5,0.5)) |> { :collision, _ } 
      Detector.collision?(c1, Fixture.circle(1.5,0.5,0.5)) |> { :collision, _ } 
      Detector.collision?(c1, Fixture.circle(1.0,1.0,0.25)) |> { :collision, _ } 
    end
    fact "Can detect misses in the SE quadrant " do
      c1 = Fixture.circle(1.0,1.0,0.5)
      Detector.collision?(c1, Fixture.circle(2.0,2.0,0.5))   |> { :no_collision, _ } 
      Detector.collision?(c1, Fixture.circle(2.0,1.0,0.125)) |> { :no_collision, _ } 
    end
    fact "Can detect collisions in the NE quadrant" do
      c1 = Fixture.circle(2.0,-1.5,0.25)
      Detector.collision?(c1, Fixture.circle(2.0,-1.5,0.25))  |> { :collision, _ } 
      Detector.collision?(c1, Fixture.circle(1.0,-1.5,1.5))   |> { :collision, _ } 
      Detector.collision?(c1, Fixture.circle(2.0,-1.25,0.25)) |> { :collision, _ } 
      Detector.collision?(c1, Fixture.circle(0.0,0.0,2.5))    |> { :collision, _ } 
    end
    fact "Can detect misses in the NE quadrant " do
      c1 = Fixture.circle(2.0,-1.5,0.25)
      Detector.collision?(c1, Fixture.circle(2.0,-2.0,0.1)) |> { :no_collision, _ } 
      Detector.collision?(c1, Fixture.circle(2.5,-0.5,0.5)) |> { :no_collision, _ } 
    end
  end
end
