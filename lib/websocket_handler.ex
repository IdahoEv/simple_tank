defmodule WebsocketHandler do
  @behaviour :cowboy_websocket_handler

  def init({tcp, http}, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_init(_TransportName, req, _opts) do
    IO.puts "init.  Starting timer"
    :erlang.start_timer(500, self(), [])
    {:ok, req, :undefined_state }
  end

  def websocket_handle({:text, msg}, req, state) do
    {:ok, json} = JSEX.decode(msg)
    #delta = %{ x: HashDict.get(json, "x"), y: HashDict.get(json, "y")}
    #IO.puts inspect(json)
    {:ok, req, handle_message(state, json)}
  end
  def websocket_handle(_rata, req, state) do    
    {:ok, req, state}
  end
  
  def handle_message(state, %{ "acceleration" => a_direction, 
                               "rotation" => r_direction,
                               "trigger" => t_state
                             }) do    
    tank_pid(state) |> SimpleTank.Tank.update_controls(
      %{ "acceleration" => a_direction,
         "rotation" => r_direction,
         "trigger" => t_state
      }
    )
    state
  end
  def handle_message(state, message) do
    IO.puts "unhandled message:  #{inspect(message)}"
    state
  end


  def websocket_info({timeout, _ref, msg}, req, state) do
    physics = SimpleTank.Tank.get_public_state(tank_pid(state))
    bullets = SimpleTank.BulletList.get(bullet_list_pid(state))
    {:ok, json} = JSEX.encode(%{ 
      player_tank_physics: physics,
      bullet_list: bullets
    })
    :erlang.start_timer(50, self(), json )
    {:reply, {:text, msg}, req, state}
  end

  def websocket_info(_info, req, state) do
    {:ok, req, state}
  end

  def bullet_list_pid(_state) do
    :bullet_list    
  end
  
  def tank_pid(_state) do
    SimpleTank.TankList.get_tank(:tank_01)
  end
  def tank2(_state) do
    SimpleTank.TankList.get_tank(:tank_02)
  end

  def websocket_terminate(_reason, _req, _state) do
    :ok
  end
end
