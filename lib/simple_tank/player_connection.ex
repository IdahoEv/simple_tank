defmodule SimpleTank.PlayerConnection do

  alias SimpleTank.Player

  # connect:  connect a new player.  Must return a tuple of the form
  # { { :text, message }, %Player{} }
  # Where the first part will be the reply section of a websocket message sent
  # back to the player, and the latter part will be the  Player struct that will
  # form the new state for the WebsocketHandler.

  # Player attempts brand new connection.  State from the SocketHandler is nil.
  def connect("new", player_name, nil) do
    { :ok, player } = SimpleTank.Game.add_player(:game, player_name, self())
    SimpleTank.Debug.print_player_registry(self())
    player_reply_with_state(player)
  end

  # Player calls 'new' or 'reconnect' but already has associated tank, the state contained a player
  def connect(_, _player_name, %Player{} = player) do
    case { :erlang.is_process_alive(player.tank_pid),  self() == player.websocket_pid() } do
      { true, true } ->
        IO.puts "Player is already connected, refusing new connection"
        SimpleTank.Debug.print_player_registry(self())
        player_reply_with_state(player)
      { _, _ } ->
        { :error, "Player submitted to connect() but tank or websocket didn't match."}
    end
  end

  # Player attempts reconnect via private_id
  def connect(private_id, player_name, nil) do
    player = case  SimpleTank.Game.reconnect_player(:game, private_id, self()) do
      { :ok, player } ->
        player
      { :not_found }  ->
        { :ok, player } = SimpleTank.Game.add_player(:game, player_name, self() )
        player
    end
    SimpleTank.Debug.print_player_registry(self())
    player_reply_with_state(player)
  end
  def connect(cmd, player_name, state) do
    IO.puts "Fallback connect/3 because nothing matched.  Args were:"
    IO.puts "#{inspect(cmd)} #{inspect(player_name)} #{inspect(state)}"
  end

  def player_reply_with_state(player) do
    IO.inspect player.private_id
    IO.inspect player.id
    reply = Poison.encode!(%{ private_id: player.private_id, id: player.id })
    { { :text, reply }, player }
  end

end
