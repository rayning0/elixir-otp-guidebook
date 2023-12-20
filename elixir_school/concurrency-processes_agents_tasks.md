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
