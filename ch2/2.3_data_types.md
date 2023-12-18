**Numbers**

an integer, a hexadecimal, and a float
```
> 1 + 0x2F / 3.0
16.666666666666664
```

Division + remainder functions
```
iex> div(10,3)
3
iex> rem(10,3)
1
```

**Strings**

```
> "Strings are #{:great}!"
"Strings are great!"

> "Strings are #{:great}!" |> String.upcase |> String.reverse
"!TAERG ERA SGNIRTS"

"Strings are binaries" |> is_binary
true
```

Show binary representation of string. Use the binary concatenation operator `<>` to attach a null byte, `<<0>>`
```
> "ohai" <> <<0>>
<<111, 104, 97, 105, 0>>

> ?o
111

> ?h
104

> IO.puts <<111, 104, 97, 105>>
ohai
```

**Char Lists**

Strings aren't char lists. A char list, as its name suggests, is a list of characters. It’s an entirely different data type than strings, and this can be confusing. Whereas strings are always enclosed in double quotes, char lists are enclosed in single quotes
``````
> 'ohai' == "ohai"
false
``````

You usually won’t use char lists in Elixir. But when talking to some Erlang libraries, you’ll have to.
``````
> :httpc.request 'http://www.elixir-lang.org'
``````

**Atoms**

Atoms serve as constants, akin to Ruby’s symbols. Atoms always start with a colon. There are two different ways to create atoms. For example, both ``:hello_atom`` and `:"Hello Atom"` are valid atoms. Atoms are not the same as strings—they’re completely separate data types. They're useful in tuples and pattern matching.

**Tuples**

``````
{200, "http://www.elixir-lang.org"}

> elem({404, "http://www.php-is-awesome.org"}, 1)
http://www.php-is-awesome.org

> put_elem({404, "http://www.php-is-awesome.org"}, 0, 503)
{503, "http://www.php-is-awesome.org"}
``````

**Maps**
a key-value pair, like a hash or dictionary

``````
> programmers = Map.put(programmers, :joe, "Erlang")
> programmers = Map.put(programmers, :matz, "Ruby")
%{joe: "Erlang", matz: "Ruby"}

> Map.put(programmers, :rasmus, "PHP")
%{joe: "Erlang", matz: "Ruby", rasmus: "PHP"}

> programmers
%{joe: "Erlang", matz: "Ruby"}
``````

All data structures in Elixir are immutable, which means you can’t make any modifications to them. Any modifications you make always leave the original ("programmers") unchanged. A modified copy is returned. Therefore, in order to capture the result, you can either rebind it to the same variable name (`programmers = Map.put(programmers, :joe, "Erlang")`) or bind the value to another variable.

**Guards** (Guard clauses: ensure arguments are always right data types. It eliminates need for if statements.)
``````
defmodule MeterToLengthConverter do
  def convert(:feet, m) when is_number(m), do: m * 3.28084
  def convert(:inch, m) when is_number(m), do: m * 39.3701
  def convert(:yard, m) when is_number(m), do: m * 1.09361
end

defmodule MeterToLengthConverter do
  def convert(:feet, m) when is_number(m) and m >= 0, do: m * 3.28084
  def convert(:inch, m) when is_number(m) and m >= 0, do: m * 39.3701
  def convert(:yard, m) when is_number(m) and m >= 0, do: m * 1.09361
end

> is_ [press Tab]
is_atom/1         is_binary/1       is_bitstring/1    is_boolean/1
is_float/1        is_function/1     is_function/2     is_integer/1
is_list/1         is_map/1          is_nil/1          is_number/1
is_pid/1          is_port/1         is_reference/1    is_tuple/1
``````
**Pattern Matching** (important in functional languages)

`=` is not just to assign/bind variables. It's also the `match operator`, matching both values and data structures.

1. Use = to assign variables:
```
programmers = Map.put(programmers, :jose, "Elixir")
```
2. Use = to match variables:
```
> %{joe: "Erlang", jose: "Elixir", matz: "Ruby", rich: "Clojure"}
 = programmers
```
This is not an assignment. Instead, a successful pattern match has occurred, since the contents of both the left side and `programmers` are identical.

Bad pattern match:
```
iex> %{tolkien: "Elvish"} = programmers
** (MatchError) no match of right hand side value: %{joe: "Erlang", jose: "Elixir", matz: "Ruby", rich: "Clojure"}

```
**Destructuring**

“Destructuring allows you to bind a set of variables to a corresponding set of values anywhere that you can normally bind a value to a single variable.”

```
> %{joe: a, jose: b, matz: c, rich: d} = %{joe: "Erlang", jose: "Elixir", matz: "Ruby", rich: "Clojure"}

> a
"Erlang"
> b
"Elixir"
> c
"Ruby"
> d
"Clojure"

> %{jose: most_awesome_language} = programmers
%{joe: "Erlang", jose: "Elixir", matz: "Ruby", rich: "Clojure"}
> most_awesome_language
"Elixir"

> Map.fetch(programmers, :rich)
{:ok, "Clojure"} <--- Map.fetch returns tuple
> Map.fetch(programmers, :rasmus)
:error
```

May use 2 different possible outputs in `case` statement:
```
case Map.fetch(programmers, :rich) do
  {:ok, language} ->
    IO.puts "#{language} is a legit language."
  :error ->
    IO.puts "No idea what language this is."
end

Clojure is a legit language.
```
