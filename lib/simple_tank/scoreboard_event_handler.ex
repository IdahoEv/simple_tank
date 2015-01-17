defmodule SimpleTank.ScoreboardEventHandler do
  use GenEvent

  # The only state this handler tracks is the PID of the scoreboard
  # that it forwards events to.
  def init(scoreboard_pid) do
    { :ok, scoreboard_pid }
  end

  def handle_event({ :tank_hit, firer_id, target_id, target_pid}, scoreboard_pid) do
    SimpleTank.Scoreboard.hit(scoreboard_pid, firer_id, target_id)
    { :ok, scoreboard_pid }
  end
  
end
