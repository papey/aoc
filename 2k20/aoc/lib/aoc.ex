defmodule AOC do
  import AOC.Helper.Input

  defmodule D1 do
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

  defmodule D2 do
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
end
