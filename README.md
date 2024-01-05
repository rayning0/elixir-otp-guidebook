## Notes on [The Little Elixir & OTP Guidebook](https://www.manning.com/books/the-little-elixir-and-otp-guidebook) (by Benjamin Tan Wei Hao) and [Elixir School](https://elixirschool.com/).

Code for book's [**Metex weather app**](https://github.com/rayning0/metex).

I urge you buy the [liveBook version](https://livebook.manning.com/book/the-little-elixir-and-otp-guidebook), where you can hear and see book read aloud.

## The Little Elixir & OTP Guidebook
- [Chp 1](ch1/what_is_elixir.md): Elixir vs. Erlang. What's Elixir good/bad for? Preview of OTP behaviors.

**Whirlwind Tour of Elixir:**
- [Chp 2.2](ch2/2.2_first-steps.md): First Steps
- [Chp 2.3-2.4](ch2/2.3-2.4_data-types_guards.md): Data Types, Guards
- [Chp 2.5](ch2/2.5_pattern-matching.md): Pattern Matching: Destructuring. Parse audio MP3 file's ID3 tag.
- [Chp 2.6](ch2/2.6_lists.md): Lists: Lists vs. Arrays. Flatten a list. Ordering of function clauses.
- [Chp 2.7-2.8](ch2/2.7-2.8_pipe-operator_erlang.md): Pipe Operator. Call Erlang from Elixir. Erlang Observer.
- [Chp 2.9](ch2/2.9_exercises.md): Exercises. [Parser for IPv4 packet headers](ch2/2.9_exercises.md#parser).

**Processes**
- [Chp 3.1-3.2](ch3/3.1-3.2_processes_weather-app_run-tests.md): Processes. Actor concurrency model. Building weather app. [Running software tests](ch3/3.1-3.2_processes_weather-app_run-tests.md#tests).
- [Chp 3.3](ch3/3.3_weather-worker.md): Weather app worker: given a location, returns its temperature.
- [Chp 3.4](ch3/3.4_processes_for_concurrency.md): Creating processes for concurrency. Receiving/sending messages.
- [Chp 3.5](ch3/3.5_collecting_results_with_another_actor.md): Collecting/Manipulating temperature results with another actor (a Coordinator).

## Elixir School
- [Computer Memory](elixir_school/memory-stack_vs_heap.md): Stack vs. Heap
- MIT course: [Concurrency: Process vs. Thread](elixir_school/mit_concurrency-process_thread_race-conditions.md). Shared memory vs. message passing. Race Conditions.
- YouTube: [Concurrency Primitives, Processes, and Message Passing - Part 8](elixir_school/yt_concurrency-primitives_processes_message-passing.md)
- [Concurrency: Processes, Agents, Tasks](elixir_school/concurrency-processes_agents_tasks.md)
- OTP Concurrency: Genserver
- OTP Supervisors
