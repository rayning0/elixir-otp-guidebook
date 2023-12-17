**Definition**

`Concurrency`: Concurrency is 2 lines of customers ordering from a single cashier (lines take turns ordering), or 1 waiter serving many customers. `Parallelism` is 2 lines of customers ordering from 2 cashiers (each line gets its own cashier).

Difference between concurrency + parallelism:
1. [Concurrency is about dealing with lot of things at once, while  parallelism is about doing lot of things at once](https://stackoverflow.com/a/76954105/2175188).
2. [Get passport + do presentation example](https://stackoverflow.com/a/24684037/2175188).

**MIT course on concurrency**

[MIT course definition](https://web.mit.edu/6.005/www/fa14/classes/17-concurrency/):
- Concurrency: multiple computations are happening at same time.
  - Multiple computers in a network
  - Multiple applications running on one computer
  - Multiple processors in a computer (today, often multiple processor cores on a single chip)

- It's everywhere in software:
  - Web sites must handle multiple simultaneous users.
  - Mobile apps need to do some of their processing on servers (“in the cloud”).
  - GUIs almost always require background work that does not interrupt the user. For example, Eclipse compiles your Java code while you’re still editing it.

- We’re getting more cores with each new generation of CPUs. So in the future, in order to run a computation faster, we must split it into concurrent pieces.

**2 Models for How Concurrent Modules Communicate**

`Shared Memory`: concurrent modules interact by reading and writing shared objects in memory. Examples:
- A and B may be 2 processors (or processor cores) in the same computer, sharing the same physical memory.
- A and B may be 2 programs running on the same computer, sharing a common filesystem with files they can read and write.
- A and B may be 2 threads in the same Java program (we’ll explain what a thread is below), sharing the same Java objects.

`Message Passing` ([Elixir/Erlang way](https://elixirschool.com/en/lessons/intermediate/concurrency#message-passing-1)): concurrent modules interact by sending messages to each other through a communication channel. Modules send off messages, and incoming messages to each module are queued up for handling. Examples:
- A and B may be 2 computers in a network communicating by network connections.
- A and B may be a web browser and a web server. A opens connection to B, asks for a web page, then B sends web page data back to A.
- A and B may be an instant messaging client and server.
- A and B may be 2 programs running on same computer whose input and output have been connected by a pipe, like `ls | grep` typed into a command prompt.

**2 Types of Concurrent Modules**

`Process`: an independent running program with its own memory space and resources. **It's isolated from other processes** on same machine. Has its own private section of the machine’s memory. Takes more time to terminate. May have these 6 states: **"New, ready, running, waiting, terminated, and suspended."** The operating system’s scheduler determines the order and duration of process execution, giving illusion of parallelism to users.

A process includes: the program code, its current activity, and a unique process ID (PID). Each process runs in its own memory space and has its own set of system resources, such as registers, variables, and file descriptors.

The process abstraction is a `virtual computer`. It makes the program feel like it has the entire machine to itself – like a fresh computer has been created, with fresh memory, just to run that program.

Just like computers connected across a network, **processes share no memory between them. A process can’t access another process’s memory or objects.** Sharing memory between processes is possible on most operating system, but it needs special effort. By contrast, a new process is automatically ready for [message passing](https://cs.lmu.edu/~ray/notes/messagepassing/).

**Processes communicate through inter-process communication mechanisms, such as message passing or shared files.**

____

`Thread`: **a lightweight unit of execution within a process that shares the same memory space**. A locus of control inside a running program. A place in the program that is being run, plus the stack of method calls that led to that place to which it will be necessary to return through. **A process may have multiple threads (`multithreading`). A thread has 3 states: "Running, Ready, and Blocked."**

**A way for a program to divide its tasks into smaller, more manageable units of work that can be executed concurrently.** Each thread can perform a different task simultaneously, letting the program to use processing power of multiple CPU cores or processors. Threads can also be used to implement concurrency and synchronization, letting multiple threads to access shared resources in a safe and controlled manner. Threads help programs run faster and more efficiently by dividing workloads and working together.

The thread abstraction represents a `virtual processor`. Making a new thread simulates making a fresh processor inside the virtual computer represented by the process. This new virtual processor **runs the same program and shares the same memory as other threads in process**.

**Threads, as part of the same process, communicate through shared memory and can directly access the same variables and data structures.**

A thread needs special effort to get “thread-local” memory that’s private to a single thread. It’s also necessary to set up message-passing explicitly, by creating and using queue data structures.

____

**Q: How can I have many concurrent threads with only 1 or 2 processors in my computer?** When there are more threads than processors, concurrency is simulated by `time slicing`: the processor switches between threads. The figure on the right shows how three threads T1, T2, and T3 might be time-sliced on a machine that has only two actual processors. In the figure, time proceeds downward, so at first one processor is running thread T1 and the other is running thread T2, and then the second processor switches to run thread T3. Thread T2 simply pauses, until its next time slice on the same processor or another processor.

On most systems, time slicing happens unpredictably and nondeterministically, meaning that a thread may be paused or resumed at any time.

**Q: Advantages of processes vs. threads?**

Processes offer greater isolation and robustness since they have separate memory spaces. This isolation can enhance system stability, but processes may have higher overhead. Threads, being lightweight and sharing resources, can be more efficient in terms of memory usage and communication but may be more prone to errors due to shared state.

**Q: When should I use processes vs. threads?**

Processes are better when strong isolation is required between tasks, like in independent applications. Threads are better when tasks must share data efficiently and communicate quickly in the same program, like in parallel computing or GUI applications.

**[Difference between Process vs. Thread](https://www.prepbytes.com/blog/operating-system/difference-between-process-and-thread/):**

1. A process is an instance for program execution. A thread is a lightweight process that exists within a process.

2. Each process has its own memory space.	Threads share same memory space as the process that created them.

3. Each process runs independently of other processes. Threads in a process share the same resources and run concurrently.

4. Processes are created and destroyed independently of each other.	Threads are created and destroyed within a process.

5. Context switching is slower in a process compared to in a thread.

6. Processes must use interprocess communication (IPC) to communicate with each other.	Threads in a process can easily share data and communicate with each other with shared memory.

7. Processes provides better security + stability than threads, since they run in separate memory spaces.	If one thread crashes, it can potentially affect other threads running in the same process.

8. A process can contain multiple threads. A thread cannot contain other threads.

9. In a process, all threads share the same `heap`.	Each thread has its own private `stack`.
