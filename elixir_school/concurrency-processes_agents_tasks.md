[Elixir School, Concurrency](https://elixirschool.com/en/lessons/intermediate/concurrency):

Elixir concurrency follows the [Actor model](https://en.wikipedia.org/wiki/Actor_model#Fundamental_concepts):

It adopts the philosophy "everything is an actor." This is similar to the "everything is an object" philosophy used by object-oriented languages.

An `actor` is a computational entity that, in response to a message it receives, can concurrently:

- send a finite number of messages to other actors;
- create a finite number of new actors;
- designate behavior used for the next message it receives;
- modify their own private state, but can only affect each other indirectly through messaging, removing need for lock-based synchronization.

There is no assumed order to these actions. They may be done in parallel.

Decoupling the sender from communications sent was a fundamental advance of the actor model, enabling asynchronous communication and control structures as patterns of passing messages.

Message receivers are identified by address, or "mailing address". An actor can only communicate with actors whose addresses it has. It can obtain those from a message it receives, or if the address is for an actor it has itself created.

The actor model has concurrency of computation within and among actors, dynamic creation of actors, inclusion of actor addresses in messages, and interaction only through direct asynchronous message passing, with no restriction on message arrival order.

**[Processes](https://hexdocs.pm/elixir/1.16/processes.html)**

Processes in the Erlang VM are lightweight (may only use 2.6 KB) and run across all CPUs. While they may seem like native threads, they’re simpler.

"In Elixir, all code runs inside processes. Processes are isolated from each other, run concurrent to one another and communicate via message passing. Processes are not only the basis for Elixir concurrency, but they provide the means for building distributed and fault-tolerant programs.

Elixir's processes should not be confused with operating system processes. Elixir processes are extremely lightweight in memory and CPU (even compared to threads, as used in many other languages). Thus it's not uncommon to have tens or even hundreds of thousands of processes running simultaneously."

The easiest way to make a process is by [spawn](https://hexdocs.pm/elixir/1.16/Kernel.html#spawn/1), which takes an anonymous or named function. When we create a new process it returns a `Process Identifier (PID)` to uniquely identify it in our app.
```
defmodule Example do
  def add(a, b) do
    IO.puts(a + b)
  end
end

Example.add(2, 3)
5
:ok
```
To run `add()` asynchronously, use [spawn/3](https://hexdocs.pm/elixir/1.16/Kernel.html#spawn/3):
```
> spawn(Example, :add, [2, 3])
5
#PID<0.80.0>
```
**Message Passing**

Processes communicate only by message passing, using [send/2](https://hexdocs.pm/elixir/1.16/Kernel.html#send/2) and [receive/1](https://hexdocs.pm/elixir/1.16/Kernel.SpecialForms.html#receive/1). `send` lets us send a message to a PID and returns the message. To listen, use `receive` to pattern match messages. If no match found, execution continues uninterrupted.
```
> defmodule Example do
    def listen do
      receive do
        {:ok, "hello"} -> IO.puts("world")
      end

      listen()
    end
  end

> pid = spawn(Example, :listen, [])
#PID<0.108.0>

> send pid, {:ok, "hello"}
world
{:ok, "hello"}

> send pid, :ok
:ok
```
`listen/0` function above is recursive, letting our process handle multiple messages. Without recursion, our process would exit after handling the first message.

**Process Linking**

How to know when a process crashes? Link our processes with [spawn_link/3](https://hexdocs.pm/elixir/1.16/Kernel.html#spawn_link/3). Two linked processes will get exit notifications from each other.

```
spawn_link(module, fun, args)

@spec spawn_link(module(), atom(), list()) :: pid()
```
Spawns given function `fun` from the given `module`, passing it the given `args`, links it to the current process, then returns its PID.

Typically developers do not use the `spawn` functions. Instead they use abstractions like `Task`, `GenServer` and `Agent`, built on top of `spawn`, that spawns processes with more conveniences in terms of introspection and debugging.

Using [exit/1](https://hexdocs.pm/elixir/1.16/Kernel.html#exit/1): "Stops execution of the calling process with the given reason."
```
defmodule Example do
  def explode, do: exit(:kaboom)
end

> spawn(Example, :explode, [])
#PID<0.66.0>

> spawn_link(Example, :explode, [])
** (EXIT from #PID<0.57.0>) evaluator process exited with reason: :kaboom
```
If we don't want a linked process to crash the current one, trap these exits with [Process.flag/2](https://hexdocs.pm/elixir/1.16/Process.html#flag/2).

`Process.flag(flag, value)` sets given `flag` to `value` for the calling process and returns old `flag` value.

When trapping exits (`trap_exit` set to true), exit signals will be received as a tuple: `{:EXIT, from_pid, reason}`.
```
defmodule Example do
  def explode, do: exit(:kaboom)

  def run do
    Process.flag(:trap_exit, true)
    spawn_link(Example, :explode, [])

    receive do
      {:EXIT, _from_pid, reason} -> IO.puts("Exit reason: #{reason}")
    end
  end
end

> Example.run
Exit reason: kaboom
:ok
```
**Process Monitoring**

How to NOT link 2 processes but still stay informed on crashes? Use [spawn_monitor/3](https://hexdocs.pm/elixir/1.16/Kernel.html#spawn_monitor/3). We get a message if the process crashes, WITHOUT our current process crashing or needing to explicitly trap exits.

```
> defmodule Example do
    def explode, do: exit(:kaboom)

    def run do
      spawn_monitor(Example, :explode, [])

      receive do
        {:DOWN, _ref, :process, _from_pid, reason} -> IO.puts("Exit reason: #{reason}")
      end
    end
  end

> Example.run
Exit reason: kaboom
:ok
```
For more: [How to Capture All Errors Returned by a Function Call in Elixir](https://semaphoreci.com/blog/2016/11/24/how-to-capture-all-errors-returned-by-a-function-call-in-elixir.html).

**[Agents](https://hexdocs.pm/elixir/1.16/agents.html#agents-101)**

Agents are an abstraction around background processes maintaining state. We can access them from other processes in our application and node. The state of our Agent is set to our function’s return value:
```
> {:ok, agent} = Agent.start_link(fn -> [1, 2, 3] end)
{:ok, #PID<0.65.0>}

> Agent.update(agent, fn (state) -> state ++ [4, 5] end)
:ok

> Agent.get(agent, &(&1))
[1, 2, 3, 4, 5]
```
When we name an Agent we can refer to it by that instead of its PID:
```
> Agent.start_link(fn -> [1, 2, 3] end, name: Numbers)
{:ok, #PID<0.74.0>}

> Agent.get(Numbers, &(&1))
[1, 2, 3]
```
More from [Elixir docs. Simple state management with Agents](https://hexdocs.pm/elixir/1.16/agents.html#content):
```
> {:ok, agent} = Agent.start_link(fn -> [] end)
{:ok, #PID<0.57.0>}
> Agent.update(agent, fn list -> ["eggs" | list] end)
:ok
> Agent.get(agent, fn list -> list end)
["eggs"]
> Agent.stop(agent)
:ok
```
We started an agent with an initial state of an empty list. We updated the agent's state, adding our new item to the head of the list. The second argument of [Agent.update/3](https://hexdocs.pm/elixir/1.16/Agent.html#update/3) is a function taking the agent's current state as input, returning its desired new state. Finally, we retrieved the whole list. The second argument of Agent.get/3 is a function that takes the state as input and returns the value that Agent.get/3 itself will return. Once we are done with the agent, we can call [Agent.stop/3](https://hexdocs.pm/elixir/1.16/Agent.html#stop/3) to terminate the agent process.

**[Tasks](https://hexdocs.pm/elixir/1.16/Task.html)**

Tasks are processes that let us execute a function in the background, then retrieve its return value later. They can be particularly useful when handling expensive operations without blocking the application execution.
```
defmodule Example do
  def double(x) do
    :timer.sleep(2000)
    x * 2
  end
end
```
Similar to `async/await` in JavaScript.
```
> task = Task.async(Example, :double, [3])
%Task{
  mfa: {Example, :double, 1},
  owner: #PID<0.113.0>,
  pid: #PID<0.120.0>,
  ref: #Reference<0.0.14467.4181767870.2579300356.114643>
}

...Do some work...

> Task.await(task)
6
```
More from [Elixir docs](https://hexdocs.pm/elixir/1.16/Task.html):

Tasks are processes meant to execute one particular action throughout their lifetime, often with little or no communication with other processes. The most common use case for tasks is to convert sequential code into concurrent code by computing a value asynchronously:
```
task = Task.async(fn -> do_some_work() end)
res = do_some_other_work()
res + Task.await(task)
```
Tasks spawned with `async` can be awaited on by their caller process (and only their caller) as shown in the example above. They are implemented by spawning a process that sends a message to the caller once the given computation is performed.

Compared to plain processes, started with `spawn/1`, tasks include monitoring metadata and logging in case of errors.

Besides `async/1` and `await/2`, tasks can also be started as part of a supervision tree and dynamically spawned on remote nodes. We will explore these scenarios next.

**async and await**

One of the common uses of tasks is to convert sequential code into concurrent code with [Task.async/1](https://hexdocs.pm/elixir/1.16/Task.html#async/1) while keeping its semantics. When invoked, a new process will be created, linked and monitored by the caller. Once the task action finishes, a message will be sent to the caller with the result.

[await/2](https://hexdocs.pm/elixir/1.16/Task.html#await/2) is used to read the message sent by the task.

2 important things when using `async`:

1. If using async tasks, you must await a reply as they are *always* sent. If you are not expecting a reply, consider using [Task.start_link/1](https://hexdocs.pm/elixir/1.16/Task.html#start_link/1) as detailed below.

2. **async tasks link the caller and the spawned process. This means if the caller crashes, the task will crash too and vice-versa.** This is on purpose: if the process meant to receive the result no longer exists, there is no purpose to finish the computation. If you don't want this link, use supervised tasks, described in a subsequent section.
