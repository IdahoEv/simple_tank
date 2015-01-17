defmodule ScoreboardEventHandlerFacts do
  use Amrita.Sweet
  alias SimpleTank.ScoreboardEventHandler

  def fixture_pid, do:   make_ref

  fact "hits call the hit function on the scoreboard" do
    tank_pid = fixture_pid
    board_pid = fixture_pid

    provided [ SimpleTank.Scoreboard.hit(board_pid, '1', '2') |> :ok ] do
      ScoreboardEventHandler.handle_event({ :tank_hit, '1', '2', tank_pid}, board_pid) |>
        { :ok, board_pid }        
    end
  end
  
end

