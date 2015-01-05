
Code.require_file "../../test_helper.exs", __ENV__.file

defmodule ListColliderFacts do
  use Amrita.Sweet

  alias Collider.ListCollider

  defmodule Fixture do
    def circle(x, y, radius) do
      { :circle, %{ position: %{ x: x, y: y}, radius: radius }  } 
    end
  end

  fact "returns the hits in a 1xN comparison of lists" do
   list_1 = [ { '12345', Fixture.circle(0, 0, 0.5 ) }] 
   list_2 = [ { '00001', Fixture.circle(2, 2, 0.1 ) },
              { '00002', Fixture.circle(0, 0.5, 0.1 ) },
              { '00003', Fixture.circle(0.3, 0.3, 0.1 ) },
              { '00004', Fixture.circle(2, 2, 0.1 ) } 
            ]
   ListCollider.find_hits(list_1, list_2) |> [ { '12345', '00002', _}, 
                                               { '12345', '00003', _} ] 
  end

end
