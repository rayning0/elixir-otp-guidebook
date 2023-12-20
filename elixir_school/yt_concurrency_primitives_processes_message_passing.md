From Tensor Programming [YouTube video](https://www.youtube.com/watch?v=EEJ2MY2Tc9A):

**Elixir - Concurrency Primitives, Processes, and Message Passing - Part 8**

To create highly available systems to run forever, must follow 3 principles:
1. `Fault tolerance`: minimize, isolate, recover from run-time errors
2. `Scalability`: can handle load increase by adding more hardware without changing/redeploying code
3. `Distribution`: can run system on multiple machines, so others can take over if 1 machine crashes

Main unit of concurrency is a `process`. Let's make anonymous function:
```
> sync_fn = fn x ->
    Process.sleep(1000)   # wait 1 second
    "#{x} return"
  end
#Function<42.105768164/1 in :erl_eval.expr/6>

> sync_fn.("test 1")
...After 1 second...
test 1 return
```
Run 5 different executions of `sync_fn`:
```
> Enum.map(1..5, &sync_fn.("test #{&1}"))
...Wait 5 seconds, since functions run SYNCHRONOUSLY...
["test 1 return", "test 2 return", "test 3 return", "test 4 return",
 "test 5 return"]
```
`&` is `capture operator`, for anonymous functions. [From this](https://stackoverflow.com/a/55094177/2175188), we see

`Enum.map([1, 2, 3], fn(x) -> add_one(x) end)` is same as

`Enum.map([1, 2, 3], &(add_one(&1))`

**How to run these function CONCURRENTLY?**

Use `spawn` to create new Elixir process. This process runs concurrent to `iex` terminal process.
```
> spawn(fn -> IO.puts(sync_fn.("test 1")) end)

#PID<0.116.0>
...After 1 second...
test 1 return
```
We may still run code in the `iex` terminal while this spawned process runs.

Make this `spawn` function a new asynchronous function:
```
> async_fn = fn x -> spawn(fn -> IO.puts(sync_fn.(x)) end) end
#Function<42.105768164/1 in :erl_eval.expr/6>

> async_fn.("test 2")
#PID<0.118.0>
...After 1 second...
test 2 return
```
**Run this asynchronous function 5 times concurrently. Result is 5 times faster!**
```
> Enum.each(1..5, &async_fn.("test #{&1}"))
:ok
...After 1 second...
test 1 return
test 2 return
test 3 return
test 4 return
test 5 return
```

**Message Passing Between 2 Processes:**

- [self()](https://hexdocs.pm/elixir/1.15.7/Kernel.html#self/0): gives process ID of current process (`iex` terminal itself)
```
> self()
#PID<0.113.0>
```
- [send(dest, message)](https://hexdocs.pm/elixir/1.15.7/Kernel.html#send/2) sends message to `dest` and returns the message. `dest` may be a remote or local PID, a local port, a locally registered name, or tuple in the form of ``{registered_name, node}` for a registered name at another node.

Send message from `iex` terminal to `iex` terminal. It goes into `iex` terminal's process mailbox:
```
> send(self(), "message to Raymond")
"message to Raymond"
```
- [receive(args)](https://hexdocs.pm/elixir/1.15.7/Kernel.SpecialForms.html#receive/1) checks process mailbox for a message matching the given clauses. If no such message matches, the current process hangs till a message arrives or waits till a given timeout value.

```
> receive do
    msg -> IO.puts(msg)
  end

message to Raymond
:ok
```

An optional `after` clause can be given if the message was not received after the given timeout period, in milliseconds. Since we already read the 1 sent message, the process mailbox is empty.
```
> receive do
    msg -> IO.puts(msg)
  after
    5000 -> IO.puts("no message in mailbox")
  end

no message in mailbox
:ok
```

Another example:
```
> send(self(), {:msg, 10})
{:msg, 10}

> result = receive do
    {:msg, x} -> x * x   # pattern matches message sent above
  end
100
```
Message passing is asynchronous. A process sends a message, then forgets it, not knowing/caring what happens in the receiver. A process waits to receive a matching message indefinitely.

**A STATEFUL process**

Make a process that remembers a state that may change over time, based on messages this process receives.

Make calculator: Start with 0. Write `add, subtract, multiply, divide` to change value over time.

```
defmodule Calc do
  def start do
    spawn(fn -> loop(0) end) # start asynchronous process with lambda function, 0 value
  end

  # client functions ---------------------------

  def view(server_pid) do
    send(server_pid, {:view, self()})

    receive do
      {:response, value} -> value
    end
  end

  def add(server_pid, value), do: send(server_pid, {:add, value})
  def sub(server_pid, value), do: send(server_pid, {:sub, value})
  def mult(server_pid, value), do: send(server_pid, {:mult, value})
  def div(server_pid, value), do: send(server_pid, {:div, value})

  # server function ---------------------------

  defp loop(current_value) do
    new_value =
      receive do
        {:view, caller_pid} ->
          send(caller_pid, {:response, current_value})
          current_value

        {:add, value} -> current_value + value
        {:sub, value} -> current_value - value
        {:mult, value} -> current_value * value
        {:div, value} -> current_value / value

        _ -> IO.puts("Invalid message") # for any other messages
      end

    loop(new_value)
  end
end
```
Start calculator:
```
> calc_pid = Calc.start
#PID<0.150.0>

> Calc.view(calc_pid)       # view current_value
0

> Calc.add(calc_pid, 20)    # add 20
{:add, 20}

> Calc.sub(calc_pid, 5)     # minus 5
> Calc.mult(calc_pid, 10)   # time 10
> Calc.view(calc_pid)
150

> Calc.div(calc_pid, 2)     # divide by 2
> Calc.view(calc_pid)
75
```
Run 100 concurrent Calc processes:
```
> pool = Enum.map(1..100, fn _ -> Calc.start end)
[#PID<0.151.0>, #PID<0.152.0>, #PID<0.153.0>, #PID<0.154.0>, #PID<0.155.0>,
 #PID<0.156.0>, #PID<0.157.0>, #PID<0.158.0>, #PID<0.159.0>, #PID<0.160.0>,
 #PID<0.161.0>, #PID<0.162.0>, #PID<0.163.0>, #PID<0.164.0>, #PID<0.165.0>,
 #PID<0.166.0>, #PID<0.167.0>, #PID<0.168.0>, #PID<0.169.0>, #PID<0.170.0>,
 #PID<0.171.0>, #PID<0.172.0>, #PID<0.173.0>, #PID<0.174.0>, #PID<0.175.0>,
 #PID<0.176.0>, #PID<0.177.0>, #PID<0.178.0>, #PID<0.179.0>, #PID<0.180.0>,
 #PID<0.181.0>, #PID<0.182.0>, #PID<0.183.0>, #PID<0.184.0>, #PID<0.185.0>,
 #PID<0.186.0>, #PID<0.187.0>, #PID<0.188.0>, #PID<0.189.0>, #PID<0.190.0>,
 #PID<0.191.0>, #PID<0.192.0>, #PID<0.193.0>, #PID<0.194.0>, #PID<0.195.0>,
 #PID<0.196.0>, #PID<0.197.0>, #PID<0.198.0>, #PID<0.199.0>, #PID<0.200.0>, ...]
```
Since each process is waiting for messages, they don't use CPU time.

**To inspect Elixir processes**, see post [Elixir Processes: Observability](https://samuelmullen.com/articles/elixir-processes-observability):

- Memory of a process (bytes): `Process.info(pid, :memory)`. Typical Elixir process uses 2.6 KB.
- 4 types of info on a process: `Process.info(pid, [:registered_name, :memory, :messages, :links])`
- `Process.info(pid, ...)` and `:erlang.process_info(pid, ...)` mean the same.
