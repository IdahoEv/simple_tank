defmodule SimpleTank.Time do

  def now do
    ts = :os.timestamp
    ( elem(ts, 0) * 1000000.0 ) +
    ( elem(ts, 1) ) +
    ( elem(ts, 2) / 1000000.0 ) 
  end

  def delta(old_time) do
    new_time = now
    { new_time - old_time, new_time }
  end
end
