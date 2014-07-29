defmodule SimpleTank do
  def start(_type, _args) do
    dispatch = :cowboy_router.compile([
      { :_, [
              {"/", :cowboy_static, {:priv_file, :simple_tank, "index.html"}},
              {"/websocket", WebsocketHandler, []},
              {"/static/[...]", :cowboy_static, {:priv_dir, :simple_tank, "static"}}
      ] }
    ])
    { :ok, _ } = :cowboy.start_http(:http, 
                                    100,
                                   [{:port, 8080}],  
                                   [{ :env, [{:dispatch, dispatch}]}]
                                   ) 
    SimpleTank.Supervisor.start_link []
  end
end
