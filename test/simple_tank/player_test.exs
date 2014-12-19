Code.require_file "../../test_helper.exs", __ENV__.file

defmodule PlayerFacts do
  use Amrita.Sweet

  alias SimpleTank.Player

  facts "new" do

    fact "two sequential players should not have the same private_id or id" do
      pl1 = Player.new('John', 'pid1')
      pl2 = Player.new('John', 'pid1')
      pl1.private_id |> !equals pl2.private_id
      pl1.id |> !equals pl2.id
    end    
  end
end


