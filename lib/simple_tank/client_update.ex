defmodule SimpleTank.ClientUpdate do

  # Send info to all connected clients about the current game
  # state.
  def send(state) do
    alias SimpleTank.PublicState

    tank_updates   = PublicState.tank_list(Dict.values(state.players))
    bullet_updates = PublicState.bullet_list(state.bullet_list)

    # TODO: only do the JSON conversion of tanks and bullet list once,
    # for optimization?
    Enum.each(state.players, fn({_id, player}) ->
      json = Poison.encode! %{
        state_update: %{
          private_id: player.private_id,
          player_tank: SimpleTank.PrivateTankState.for_tank(player),
          bullets: bullet_updates,
          tanks: tank_updates
        }
      }
      send player.websocket_pid, { :update, json }
    end)
  end
end
