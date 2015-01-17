

defmodule TankEventHandlerFacts do
  use Amrita.Sweet
  alias SimpleTank.TankEventHandler

  def fixture_pid, do:   make_ref
  def fixture_id(n), do: "00000#{n}"

  fact "for tank list" do
    tank_pid = fixture_pid

    provided [ SimpleTank.Tank.receive_hit(tank_pid) |> :ok ] do
      TankEventHandler.handle_event({ :tank_hit, '1', '2', tank_pid}, []) |>
        { :ok, [] }        
    end
  end
  
end

