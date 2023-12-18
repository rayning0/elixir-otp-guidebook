# Elixir has no arrays, just linked lists. Why: https://www.openmymind.net/Elixir-A-Little-Beyond-The-Basics-Part-1-lists/
[1, 2, 3] == [1 | [2 | [3 | []]]]

defmodule MyList do
  def flatten([]), do: []
  def flatten([ head | tail ]) do
    flatten(head) ++ flatten(tail)
  end
  def flatten(head), do: [ head ]
end
