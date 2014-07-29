defmodule SimpleTank do
  def start(_type, _args) do
    SimpleTank.Supervisor.start_link []
  end
end
