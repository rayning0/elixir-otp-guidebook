Don't confuse MEMORY terms "stack" and "heap" with DATA STRUCTURES "stack" and "heap," which have different purposes + functions.

[Computer Memory: Stack vs. Heap](https://www.educative.io/blog/stack-vs-heap):

**Memory Allocation**

Designating specific area in our computer’s memory for a distinct purpose, space to store data and all the commands our program requires to operate efficiently. Every program has its own virtual memory layout, mapped onto physical memory by the operating system.

Memory may be divided into these parts:

1. `Global segment`: stores global and static variables with lifetime equal to whole duration of the program's execution.

2. `Code segment/Text segment`: actual machine code or instructions of our program, including functions and methods.

3. `Stack segment`: used to manage local variables, function arguments, and control information, like return memory addresses.

4. `Heap segment`: flexible area to store large data structures and objects with dynamic lifetimes. Heap memory may be allocated or deallocated during program execution.

Global variables declared outside any function live in the global segment. Machine code or instructions for the program's functions and methods are stored in the code segment.

- Python example:
```
# Global Segment: Global variables stored here
globalVar = 42

# Code Segment: Functions and methods stored here
def add(a, b):
    return a + b

# Code Segment: Calling the add function
sum = add(globalVar, 10)

print("Sum:", sum)
```

**Stack memory: fixed, organized, and efficient storage.** It uses a last in, first out (LIFO) approach, or most recent data added gets removed first. The kernel, a central part of operating system, manages stack memory automatically; we don't worry about allocating and deallocating stack memory.
```
# Function to add two numbers
def add(a, b):
    # Local variables (stored in stack)
    sum = a + b
    return sum

# Local variable (stored in stack)
x = 5

# Function call (stored in stack)
result = add(x, 10)

print("Result:", result)
```

A block of memory called a `stack frame` is created when a function is called. It stores info related to local variables, parameters, and the function's return address. This memory is created on the stack segment.

- C++ example:
```
1. #include <iostream>
2.
3. // A simple function to add two numbers
4. int add(int a, int b) {
5.    // Local variables (stored in stack)
6.    int sum = a + b;
7.    return sum;
8. }
9.
10. int main() {
11.    // Local variable (stored in stack)
12.    int x = 5;
13.
14.    // Function call (stored in stack)
15.    int result = add(x, 10);
16.
17.    std::cout << "Result: " << result << std::endl;
18.
19.    return 0;
20. }
```
How this C++ code runs, in execution order:

Line 10: The program starts with the main function, and a new stack frame is created for it.

Line 12: The local variable `x` is assigned the value 5.

Line 15: The add the function is called with the arguments `x` and 10.

Line 4: A new stack frame is created for the `add` function. The control is transferred to the add function with local variables. `a, b, and sum`. Variables `a and b` are assigned the values of `x and 10`, respectively.

Line 6: The local variable sum is assigned the value of `a + b` (i.e., 5 + 10).

Line 7: The sum variable's value (i.e., 15) is returned to the caller.

Line 8: The add function's stack frame is popped from the stack, and all local variables (`a, b, and sum`) are deallocated.

Line 15: The local variable result on the stack frame of the main function is assigned the returned value (i.e., 15).

Line 17: The value stored in the result variable (i.e., 15) is printed to the console using `std::cout`.

Line 19: The main function returns 0, signaling successful execution.

Line 20: The main function's stack frame is popped from the stack, and all local variables (`x and result`) are deallocated.

**Key features of stack memory:**

- Fixed size: When it comes to stack memory, its size remains fixed and is determined right at the beginning of the program’s execution.

- Speed advantage: Stack memory frames are contiguous. Therefore, allocating and deallocating memory in stack memory is incredibly quick. This is done through simple adjustment of references through stack pointers managed by the OS.

- Storage for control info and variables: Stack memory is responsible for housing control information, local variables, and function arguments, including return addresses.

- Limited accessibility: It's important to remember that data stored in stack memory can only be accessed during an active function call.

- Automatic management: The efficient management of stack memory is handled by the system itself, requiring no extra effort on our part.

**Heap memory: dynamic storage.** Engineer must manage it manually. It lets us allocate and free up memory any time during our program's execution. Great to store large data structures or objects with sizes unknown in advance.

- Python example:
```
def main():
    # Stack: Local variable 'value' is stored on stack
    value = 42

    # Heap: Allocate memory for a single integer on the heap
    ptr = [None]  # Using list with a single None element to simulate pointer-like behavior

    # Assign value to the allocated memory and print it
    ptr[0] = value
    print("Value:", ptr[0])

    # In Python, garbage collection is automatic, so no need to deallocate memory

main()
```
In code example, we want to store value 42 in heap memory, a more permanent and flexible storage space. Do it with a pointer or reference variable that resides in stack memory:

`int* ptr` in C++.

An `Integer` object `ptr` in Java.

A list with a single element `ptr` in Python.

In C++, we must manually release memory allocated on the heap using the `delete` keyword. However, Python and Java manage memory deallocation automatically through garbage collection, so no need for manual intervention.

- C++ example:
```
1. #include <iostream>
2.
3. int main() {
4.    // Stack: Local variable 'value' is stored on the stack
5.    int value = 42;
6.
7.    // Heap: Allocate memory for a single integer on the heap
8.    int* ptr = new int;
9.
10.    // Assign the value to the allocated memory and print it
11.    *ptr = value;
12.    std::cout << "Value: " << *ptr << std::endl;
13.
14.    // Deallocate memory on the heap
15.    delete ptr;
16.
17.    return 0;
18.}
```
How this C++ code runs, in execution order:

Line 3: The function main is called, and a new stack frame is created for it.

Line 5: A local variable value on the stack frame is assigned the value 42.

Line 8: A pointer variable `ptr` is allocated the dynamically created memory for a single integer on the heap using the new keyword. Let's assume the address of this new memory on the heap to be `0x1000`. The address of the allocated heap memory (`0x1000`) is stored in the pointer `ptr`.

Line 11: The integer value 42 is assigned to the memory location pointed to by `ptr` (heap address `0x1000`).

Line 12: The value stored at the memory location pointed to by `ptr` (42) is printed to the console.

Line 15: The memory allocated on the heap at address `0x1000` is deallocated using the `delete` keyword. After this line, `ptr` becomes a dangling pointer because it still holds the address `0x1000`, but that memory has been deallocated. However, we will not discuss dangling pointers in detail for this essential discussion.

Line 17: The main function returns 0, signaling successful execution.

Line 18: The main function's stack frame is popped from the stack, and all local variables (`value` and `ptr`) are deallocated.


**Key features of heap memory:**

- Flexible size: Heap memory size can change throughout program's execution.

- Speed trade-off: Allocating and deallocating memory in a heap is slower because it involves finding a suitable memory frame and handling fragmentation.

- Storage for dynamic objects: Heap memory stores objects and data structures with dynamic lifespans, like those created with the `new` keyword in Java or C++.

- Persistent data: Data stored in heap memory stays there until we manually deallocate it or the program ends.

- Manual management: In some programming languages (like C and C++), heap memory must be managed manually. This can lead to memory leaks or inefficient use of resources if done incorrectly.

**Difference between Stack vs. Heap:**

- Size management: Stack memory has a fixed size determined at the beginning of the program's execution. Heap memory has flexible size that can change throughout program's lifecycle.

- Speed: Stack memory is faster when allocating and deallocating memory because it only requires adjusting a reference. Heap memory is slower due to the need to locate suitable memory frames and manage fragmentation.

- Storage purposes: Stack memory is for control information (like function calls and return addresses), local variables, and function arguments, including return addresses. Heap memory is for storing objects and data structures with dynamic lifespans, like those created with `new` keyword in Java or C++.

- Data accessibility: Data in stack memory can only be accessed during an active function call. Data in heap memory remains accessible till it's manually deallocated or the program ends.

- Memory management: The system automatically manages stack memory, optimizing usage for fast + efficient memory referencing. In contrast, heap memory management is the engineer's responsibility, and improper handling can lead to memory leaks or inefficient use of resources.

**When to use stack memory vs. heap memory**

Use Stack to store local variables, temporary storage, and function arguments with short, predictable lifespan in C++, Java, and Python.

Use Heap when
- Need to store objects, data structures, or dynamically allocated arrays with unpredictable lifespans (at compile time or in a function call).

- Memory requirements are large or need to share data between different parts of our program.

- We must allocate memory that persists beyond scope of a single function call.

In C++, we need manual memory management (with `delete`).
Java and Python automatically deallocates memory with garbage collection.
