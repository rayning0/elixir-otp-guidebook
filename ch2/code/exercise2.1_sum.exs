# With Enum.reduce/3: https://hexdocs.pm/elixir/Enum.html#reduce/3
defmodule Ex0 do
  def sum(list) do
    Enum.reduce(list, 0, fn x, acc -> acc + x end)
  end
end

# With recursion: https://www.leighhalliday.com/recursion-in-elixir
defmodule Ex1 do
  def sum(list, acc \\ 0)

  def sum([], acc) do
    acc
  end

  def sum([head | tail], acc) do
    sum(tail, acc + head)
  end

  def sum(range, _acc) do
    # Elixir lacks is_range() guard. All ranges are maps.
    if range |> is_map do
      range |> Enum.to_list() |> sum()
    end
  end
end

# With for/1 (list comprehension) with :reduce option
# https://hexdocs.pm/elixir/Kernel.SpecialForms.html#for/1-the-reduce-option
# https://hexdocs.pm/elixir/comprehensions.html
# https://elixirschool.com/en/lessons/basics/comprehensions)
# https://www.mitchellhanberg.com/the-comprehensive-guide-to-elixirs-for-comprehension/#reduce
defmodule Ex2 do
  def sum(list) do
    for x <- list, reduce: 0 do
      acc -> x + acc
    end

    # This returns total = 0

    # total = 0
    # for x <- list, do: total = total + x
    # total
  end
end

ExUnit.start()

defmodule SumTest do
  use ExUnit.Case, async: true

  test "sum() adds all numbers in list, with Enum.reduce/3" do
    assert Ex0.sum([]) == 0
    assert Ex0.sum([1, 5, 10]) == 16
    assert Ex0.sum([-5, 3, 2.5]) == 0.5
  end

  test "sum() adds all numbers in range, with Enum.reduce/3" do
    assert Ex0.sum(0..0) == 0
    assert Ex0.sum(1..10) == 55
    assert Ex0.sum(-5..3) == -9

    # Adds [1, 3, 5]
    # Range syntax means first..last//step: https://hexdocs.pm/elixir/Kernel.html#..///3
    assert Ex0.sum(1..5//2) == 9
  end

  test "sum() adds all numbers in list, with recursion" do
    assert Ex1.sum([]) == 0
    assert Ex1.sum([1, 5, 10]) == 16
    assert Ex1.sum([-5, 3, 2.5]) == 0.5
  end

  test "sum() adds all numbers in range, with recursion" do
    assert Ex1.sum(0..0) == 0
    assert Ex1.sum(1..10) == 55
    assert Ex1.sum(-5..3) == -9
    assert Ex1.sum(1..5//2) == 9
  end

  test "sum() adds all numbers in list, with list comprehension" do
    assert Ex2.sum([]) == 0
    assert Ex2.sum([1, 5, 10]) == 16
    assert Ex2.sum([-5, 3, 2.5]) == 0.5
  end

  test "sum() adds all numbers in range, with list comprehension" do
    assert Ex2.sum(0..0) == 0
    assert Ex2.sum(1..10) == 55
    assert Ex2.sum(-5..3) == -9
    assert Ex2.sum(1..5//2) == 9
  end
end
