defmodule Ex do
  def transform1(list) do
    list |> List.flatten() |> Enum.reverse() |> Enum.map(fn x -> x * x end)
  end

  def transform2(list) do
    Enum.map(Enum.reverse(List.flatten(list)), fn x -> x * x end)
  end
end

ExUnit.start()

defmodule TransformTest do
  use ExUnit.Case, async: true

  test "transform() a list with pipe operator" do
    assert Ex.transform1([1, [[2], 3]]) == [9, 4, 1]
  end

  test "transform() a list without pipe operator" do
    assert Ex.transform2([1, [[2], 3]]) == [9, 4, 1]
  end
end
