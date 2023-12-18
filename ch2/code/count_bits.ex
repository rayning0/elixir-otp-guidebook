# Elixir bitstrings
# https://dev.to/aaronc81/elixirs-bitstrings-the-data-type-i-didnt-know-i-wanted-2842

# A binary is a special case of the real data type called a bitstring. A bitstring is a binary if the number of bits is divisible by 8.

# Combine this with Elixir's pattern matching on method definitions, to counts number of 1 bits in a bitstring:
defmodule Count do
  # If the next bit is 1, count it and recurse
  def count_bits(<<1::1, rest::bitstring>>), do: 1 + count_bits(rest)

  # If the next bit is 0, don't count it and recurse
  def count_bits(<<0::1, rest::bitstring>>), do: count_bits(rest)

  # Base case: if bits have run out, stop
  def count_bits(<<>>), do: 0
end

IO.puts(Count.count_bits(<<55>>))
# => 5
# That's right! 55 is 0b00110111
