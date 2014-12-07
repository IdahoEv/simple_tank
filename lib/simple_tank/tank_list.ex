defmodule SimpleTank.TankList do
  use GenServer

  #####
  # External API

  def start_link() do
    GenServer.start_link( __MODULE__, %{}, name: :tank_list)
  end

  def add_tank(pid, name, tank_pid) do
    GenServer.cast pid, {:add_tank, name, tank_pid}
  end

  def get_tank_list do
    GenServer.call :tank_list, :get_tank_list
  end
  def get_tank(tank_name) do
     GenServer.call :tank_list, { :get_tank, tank_name }
  end   
  def get_length do
    GenServer.call :tank_list, :get_length
  end


  #####                     
  # GenServer implementation
  def handle_call(:get_tank_list, _from, tank_list) do
    { :reply, tank_list, tank_list }
  end
  def handle_call({:get_tank, tank_name}, _from, tank_list) do
    { :reply, tank_list[tank_name], tank_list }
  end

  def handle_cast({:add_tank, name, tank_pid}, tank_list) do
    { :noreply, Dict.put(tank_list, name, tank_pid)}
  end
  def handle_call(:get_length, _from, tank_list) do
    { :reply, length(tank_list), tank_list }
  end
end

