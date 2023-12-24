defmodule MyList do
  def flatten([head | tail]) do
    flatten(head) ++ flatten(tail)
  end

  def flatten([]), do: []

  def flatten(head), do: [head]
end
