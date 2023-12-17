# defmodule MeterToLengthConverter do
#   defmodule Feet do
#     m * 3.28084
#   end

#   defmodule Inch do
#     m * 39.3701
#   end
# end

# using function clauses
defmodule MeterToLengthConverter do
  def convert(:feet, m) do
    m * 3.28084
  end

  def convert(:inch, m) do
    m * 39.3701
  end

  # OR single line version of function clauses and guards
  # def convert(:feet, m) when is_number(m) and m >= 0, do: m * 3.28084
  # def convert(:inch, m) when is_number(m), do: m * 39.3701
  # def convert(:yard, m) when is_number(m), do: m * 1.09361
end

IO.puts(MeterToLengthConverter.convert(:feet, 10))
