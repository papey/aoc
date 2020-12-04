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

  defmodule D3 do
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

  defmodule D4 do
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

    def valid_value?(key, val) do
      case key do
        "byr" ->
          is_between_range?(val, {1920, 2002})

        "iyr" ->
          is_between_range?(val, {2010, 2020})

        "eyr" ->
          is_between_range?(val, {2020, 2030})

        "hgt" ->
          case Regex.run(~r/(\d+)(in|cm)/, val) do
            [_, match, "in"] -> is_between_range?(match, {59, 76})
            [_, match, "cm"] -> is_between_range?(match, {150, 193})
            _ -> false
          end

        "hcl" ->
          Regex.match?(~r/#(?:[a-f0-9]){6}/, val)

        "ecl" ->
          Enum.member?(["amb", "blu", "brn", "gry", "grn", "hzl", "oth"], val)

        "pid" ->
          Regex.match?(~r/^(?:[0-9]){9}$/, val)

        _ ->
          true
      end
    end

    def valid?(pass, hardened \\ false) do
      fields =
        Enum.reduce(String.split(pass, " "), MapSet.new(), fn e, acc ->
          [key, val] = String.split(e, ":")

          if hardened do
            if valid_value?(key, val) do
              MapSet.put(acc, key)
            else
              acc
            end
          else
            MapSet.put(acc, key)
          end
        end)

      MapSet.subset?(@mandatory, fields)
    end
  end
end
