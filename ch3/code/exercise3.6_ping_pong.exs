defmodule PingReceiver do
  def loop(count \\ 0) do
    receive do
      {:ping, sender_pid} ->
        if count == 4 do
          send(self(), :exit)
        end

        count = count + 1
        IO.puts("Got ping. Sending pong back. Count: #{count}")
        send(sender_pid, {:pong, self()})
        loop(count)

      :exit ->
        IO.puts("Ending after #{count} ping/pongs.")
        Process.exit(self(), :kill)
    end

    loop()
  end
end

defmodule PongReceiver do
  def loop do
    receive do
      {:pong, sender_pid} ->
        IO.puts("Got pong. Sending ping back.")
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
  end
end

PingPong.run()

# OUTPUT:

# Got ping. Sending pong back. Count: 1
# Got pong. Sending ping back.
# Got ping. Sending pong back. Count: 2
# Got pong. Sending ping back.
# Got ping. Sending pong back. Count: 3
# Got pong. Sending ping back.
# Got ping. Sending pong back. Count: 4
# Got pong. Sending ping back.
# Got ping. Sending pong back. Count: 5
# Ending after 5 ping/pongs.
# Got pong. Sending ping back.
