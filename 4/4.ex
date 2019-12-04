defmodule AOC do
  def run(input) do
    [begin, ending] = read_input(input)

    # for possible password
    begin..ending
    # Check if it's a valid password
    |> Enum.map(fn current -> valid_password?(current) end)
    |> Enum.filter(fn e -> e == true end)
    |> Enum.count()
  end

  # Read input from file
  def read_input(input) do
    # input
    input
    # goes into stream (read line by line)
    |> File.stream!()
    # Flat map is used to not have a list of lists
    |> Enum.flat_map(fn l ->
      # Split on "-", then convert to int
      String.split(l, "-") |> Enum.map(fn e -> String.to_integer(e) end)
    end)
  end

  # Check if it's a valid password, return true or false
  def valid_password?(password) do
    # First case, all digits are the same
    # Convert to string, split each digit to an array

    data =
      password
      # to string
      |> Integer.to_string()
      # to array of characters
      |> String.graphemes()
      # to array of ints
      |> Enum.map(fn e -> String.to_integer(e) end)

    # check all the rules
    first_rule?(data) && second_rule?(data)
  end

  # Ensure there is two adjacent same digit in the number
  def first_rule?(password) do
    # Chunk by 2, going 1 forward at each step, ensure all pair of 2 digits are checked
    Enum.chunk_every(password, 2, 1)
    # Return true if ONE THING is true
    |> Enum.any?(fn
      [a, b] -> a == b
      # There are cases where the last chunked part is only one digit
      # Since this is an any mapping, returning false will not change results
      [_] -> false
    end)
  end

  # Ensure adjacent digits are always a <= b
  def second_rule?(password) do
    # Chunk by 2, going 1 forward at each step, ensure all pair of 2 digits are checked
    Enum.chunk_every(password, 2, 1)
    # Returns true if EVERYTHING is true
    |> Enum.all?(fn
      [a, b] ->
        a <= b

      # With this edge case, ensure true, to keep Enum.all happy
      [_] ->
        true
    end)
  end
end
