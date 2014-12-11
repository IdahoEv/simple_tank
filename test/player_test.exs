Code.require_file "../test_helper.exs", __ENV__.file

defmodule PlayerFacts do
  use Amrita.Sweet

  alias SimpleTank.Player

  facts "new" do

    fact "two sequential players should not have the same player_id" do
      pl1 = Player.new('John', 'pid1', 'pid2')
      pl2 = Player.new('John', 'pid1', 'pid2')
      pl1.player_id |> !equals pl2.player_id
    end    
  end
end


