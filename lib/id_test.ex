defmodule IDTest do
  def repeat(0, function) do
    function.()
  end
  def repeat(n, function) do
    function.()
    repeat(n-1, function)
  end

  def uuid1(n) do
    repeat(n, &UUID.uuid1/0) 
  end
  def uuid4(n) do
    repeat(n, &UUID.uuid4/0) 
  end
  def nsec(n) do
    repeat(n, &SimpleTank.Time.uniq_nanosec/0) 
  end
end

