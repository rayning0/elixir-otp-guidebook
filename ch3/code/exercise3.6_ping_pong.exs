defmodule PingReceiver do
  def loop do
    receive do
      {:ping, sender_pid} ->
        IO.puts("Got ping. Sending pong back to #{sender_pid}.")
        send(sender_pid, {:pong, self()})
    end

    loop()
  end
end

defmodule PongReceiver do
  def loop do
    receive do
      {:pong, sender_pid} ->
        IO.puts("Got pong. Sending ping back to #{sender_pid}.")
        send(sender_pid, {:ping, self()})
    end

    loop()
  end
end

defmodule PingPong do
  def run do
    ping_pid = spawn(PingReceiver, :loop, [])
    pong_pid = spawn(PongReceiver, :loop, [])
    send(ping_pid, {:ping, pong_pid})
    send(pong_pid, {:pong, ping_pid})
  end
end

PingPong.run()
