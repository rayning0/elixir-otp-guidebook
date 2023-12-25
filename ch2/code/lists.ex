defmodule MyList do
  def flatten([head | tail]) do
    flatten(head) ++ flatten(tail)
  end

  # This function MUST be before next function, else it never runs
  def flatten([]), do: []

  def flatten(head), do: [head]
end
