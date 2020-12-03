defmodule AOC.Helper do
  defmodule Input do
    @base "inputs"

    def get_input(day) do
      File.read!(Path.join(@base, String.upcase(day) <> ".input"))
    end

    def split_input(input) do
      String.split(input, "\n", trim: true)
    end
  end

  defmodule Combinator do
    def combine(input, len)
    def combine(_, 0), do: [[]]
    def combine([], _), do: []

    def combine([h | t], len),
      do: Enum.map(combine(t, len - 1), &[h | &1]) ++ combine(t, len)
  end
end
