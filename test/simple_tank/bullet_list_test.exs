defmodule BulletListFacts do
  use Amrita.Sweet 

  alias SimpleTank.BulletList

  def fixture_tank do
    %SimpleTank.Tank{}
  end 

  def fixture_game_state do
    %SimpleTank.Game{}
  end

  fact "add_bullet puts a new bullet in the list" do
    tank       = fixture_tank
    game_state = fixture_game_state

    length((s2 = BulletList.add_bullet(game_state, tank)).bullet_list) |> 1
    length((s3 = BulletList.add_bullet(s2,         tank)).bullet_list) |> 2
    length(      BulletList.add_bullet(s3,         tank).bullet_list) |> 3        
  end
  
end
