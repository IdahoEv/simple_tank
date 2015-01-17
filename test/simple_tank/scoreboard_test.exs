defmodule ScoreboardFacts do
  use Amrita.Sweet
  
  alias SimpleTank.Scoreboard
  
  facts "scoring hits" do
    fact "with empty scoreboard" do
      {:noreply, board_data} = Scoreboard.handle_cast({:hit, 'pl1', 'pl2'}, %Scoreboard{} )
      board_data.hits |> equals %{'pl1' => %{ 'pl2' => 1 } }      
    end

    fact "on an already-hit target" do
      old = %Scoreboard{ hits: %{ 'pl1' => %{ 'pl2' => 1 }}}
      {:noreply, new} = Scoreboard.handle_cast({:hit, 'pl1', 'pl2'}, old )
      new.hits |> equals %{'pl1' => %{ 'pl2' => 2 } }      
    end

    fact "on a new target for an already-entered source" do
      old = %Scoreboard{ hits: %{ 'pl1' => %{ 'pl2' => 2 }}}
      {:noreply, new} = Scoreboard.handle_cast({:hit, 'pl1', 'pl3'}, old )
      new.hits |> equals %{'pl1' => %{ 'pl2' => 2, 'pl3' => 1 } }      
    end
  end

end
