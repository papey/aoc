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
      |> Enum.map(fn v ->
        {int, _} = Integer.parse(v)
        int
      end)
      |> AOC.Helper.Combinator.combine(len)
      |> Enum.find(&(Enum.sum(&1) == 2020))
      |> List.flatten()
      |> Enum.reduce(1, &(&2 * &1))
    end
  end
end
