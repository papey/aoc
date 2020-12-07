defmodule AOC.D1 do
  import AOC.Helper.Input

  def run1() do
    solve(2)
  end

  def run2() do
    solve(3)
  end

  def solve(len) do
    get_input("D1")
    |> split_input()
    |> Enum.map(&String.to_integer/1)
    |> AOC.Helper.Combinator.combine(len)
    |> Enum.find(&(Enum.sum(&1) == 2020))
    |> List.flatten()
    |> Enum.reduce(1, &(&2 * &1))
  end
end

defmodule AOC.D2 do
  import AOC.Helper.Input
  @pattern ~r/(\d+)-(\d+) ([a-z]): ([a-z]+)/

  def run1() do
    get_input("D2")
    |> split_input()
    |> Enum.filter(fn v ->
      [_, min, max, char, pass] = Regex.run(@pattern, v)
      occurences = String.graphemes(pass) |> Enum.count(&(&1 == char))
      String.to_integer(min) <= occurences && occurences <= String.to_integer(max)
    end)
    |> Enum.count()
  end

  def run2() do
    get_input("D2")
    |> split_input()
    |> Enum.filter(fn v ->
      [_, first, second, char, pass] = Regex.run(@pattern, v)
      graphemes = String.graphemes(pass)
      first = String.to_integer(first) - 1
      second = String.to_integer(second) - 1

      cond do
        Enum.at(graphemes, first) == Enum.at(graphemes, second) ->
          false

        Enum.at(graphemes, first) == char ->
          Enum.at(graphemes, second) != char

        true ->
          Enum.at(graphemes, second) == char
      end
    end)
    |> Enum.count()
  end
end

defmodule AOC.D3 do
  import AOC.Helper.Input

  defmodule Direction do
    defstruct r: 3, d: 1, l: 0, u: 0
  end

  def run1() do
    map =
      get_input("D3")
      |> split_input()

    follow_slope(%Direction{}, map, 3, 1, 0)
  end

  def run2() do
    dirs = [
      %Direction{r: 1, d: 1},
      %Direction{r: 3, d: 1},
      %Direction{r: 5, d: 1},
      %Direction{r: 7, d: 1},
      %Direction{r: 1, d: 2}
    ]

    map =
      get_input("D3")
      |> split_input()

    Enum.map(dirs, &follow_slope(&1, map, &1.r, &1.d, 0))
    |> Enum.reduce(1, &(&2 * &1))
  end

  def gen_local_map(map, ridx, didx) do
    line = Enum.at(map, didx)
    String.graphemes(String.duplicate(line, div(ridx, String.length(line)) + 1))
  end

  def follow_slope(dir, map, ridx, didx, trees) when didx < length(map) do
    case Enum.at(gen_local_map(map, ridx, didx), ridx) do
      "#" ->
        follow_slope(dir, map, ridx + dir.r, didx + dir.d, trees + 1)

      "." ->
        follow_slope(dir, map, ridx + dir.r, didx + dir.d, trees)
    end
  end

  def follow_slope(_dir, _map, _ridx, _didx, trees), do: trees
end

defmodule AOC.D4 do
  import AOC.Helper.Input

  @mandatory MapSet.new(["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"])

  def run1() do
    get_input("D4")
    |> String.split("\n\n", trim: true)
    |> Enum.map(&String.replace(&1, "\n", " "))
    |> Enum.filter(&valid?/1)
    |> Enum.count()
  end

  def run2() do
    get_input("D4")
    |> String.split("\n\n", trim: true)
    |> Enum.map(&String.replace(&1, "\n", " "))
    |> Enum.filter(&valid?(&1, true))
    |> Enum.count()
  end

  def is_between_range?(input, {min, max}) do
    case Integer.parse(input) do
      :error -> false
      {val, _} -> min <= val && val <= max
    end
  end

  def valid_value?("byr", value), do: is_between_range?(value, {1920, 2002})
  def valid_value?("iyr", value), do: is_between_range?(value, {2010, 2020})
  def valid_value?("eyr", value), do: is_between_range?(value, {2020, 2030})
  def valid_value?("hcl", value), do: Regex.match?(~r/#(?:[a-f0-9]){6}/, value)

  def valid_value?("ecl", value),
    do: Enum.member?(["amb", "blu", "brn", "gry", "grn", "hzl", "oth"], value)

  def valid_value?("pid", value), do: Regex.match?(~r/^(?:[0-9]){9}$/, value)

  def valid_value?("hgt", value) do
    case Regex.run(~r/(\d+)(in|cm)/, value) do
      [_, match, "in"] -> is_between_range?(match, {59, 76})
      [_, match, "cm"] -> is_between_range?(match, {150, 193})
      _ -> false
    end
  end

  def valid_value?(_, _), do: true

  def valid?(pass, hardened \\ false) do
    fields =
      Enum.reduce(String.split(pass, " "), MapSet.new(), fn e, acc ->
        [key, val] = String.split(e, ":")

        if !hardened || valid_value?(key, val) do
          MapSet.put(acc, key)
        else
          acc
        end
      end)

    MapSet.subset?(@mandatory, fields)
  end
end

defmodule AOC.D5 do
  import AOC.Helper.Input

  def run1() do
    get_input("D5")
    |> split_input()
    |> Enum.map(&compute_seat_id/1)
    |> Enum.max()
  end

  def run2() do
    board_list =
      get_input("D5")
      |> split_input()
      |> Enum.map(&compute_seat_id/1)
      |> Enum.sort()

    [head_id | _] = board_list

    {mismatch, _index} =
      Enum.with_index(board_list, head_id)
      |> Enum.take_while(fn {value, index} -> value == index end)
      |> List.last()

    mismatch + 1
  end

  def compute_seat_id(input) do
    Regex.replace(~r/(F|B|L|R)/, input, fn
      _, "F" -> "0"
      _, "B" -> "1"
      _, "L" -> "0"
      _, "R" -> "1"
    end)
    |> String.to_integer(2)
  end
end

defmodule AOC.D6 do
  import AOC.Helper.Input

  def run1() do
    get_input("D6")
    |> String.split("\n\n", trim: true)
    |> Enum.reduce(0, fn v, acc ->
      count =
        String.replace(v, "\n", "")
        |> String.graphemes()
        |> Enum.uniq()
        |> Enum.count()

      acc + count
    end)
  end

  def run2() do
    get_input("D6")
    |> String.split("\n\n", trim: true)
    |> Enum.reduce(0, fn v, acc ->
      group = String.split(v, "\n")
      len = Enum.count(group)

      count =
        String.replace(v, "\n", "")
        |> String.graphemes()
        |> Enum.frequencies()
        |> Enum.to_list()
        |> Enum.filter(fn {_answer, f} -> f == len end)
        |> Enum.count()

      acc + count
    end)
  end
end
