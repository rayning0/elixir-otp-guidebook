defmodule Ex do
  def sum(list) do
    Enum.sum(list)
  end

  def sum(range) do
  end
end

ExUnit.start()

defmodule SumTest do
  use ExUnit.Case, async: true

  test "sum() adds all numbers in list" do
    assert Ex.sum([]) == 0
    assert Ex.sum([1, 5, 10]) == 16
    assert Ex.sum([-5, 3, 2.5]) == 0.5
  end

  test "sum() adds all numbers in range" do
    assert Ex.sum(0..0) == 0
    assert Ex.sum(1..10) == 55
    assert Ex.sum(-5..3) == -9
  end
end
