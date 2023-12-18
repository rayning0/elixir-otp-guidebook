defmodule Ex do
  def sum(list) do
    # Enum.sum(list)
    # Enum.reduce(list, fn num, acc -> num + acc end)
    total = 0
    for num <- list, do: total = total + num
    total
  end
end

IO.puts(Ex.sum([5,10,15]))
