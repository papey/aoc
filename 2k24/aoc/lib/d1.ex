defmodule D1 do
  def p1 do
    Parser.parse("inputs/d1.txt")
    |> Enum.map(&String.split(&1, ~r/\s+/))
    |> Enum.map(fn [a, b] -> {String.to_integer(a), String.to_integer(b)} end)
    |> Enum.unzip()
    |> then(fn {l1, l2} -> {Enum.sort(l1), Enum.sort(l2)} end)
    |> then(fn {l1, l2} -> Enum.zip(l1, l2) end)
    |> Enum.map(fn {a, b} -> abs(a - b) end)
    |> Enum.sum()
  end

  def p2 do
    Parser.parse("inputs/d1.txt")
    |> Enum.map(&String.split(&1, ~r/\s+/))
    |> Enum.map(fn [a, b] -> {String.to_integer(a), String.to_integer(b)} end)
    |> Enum.unzip()
    |> then(fn {l1, l2} ->
      Enum.map(l1, fn v1 -> v1 * Enum.count(l2, fn v2 -> v1 == v2 end) end)
      |> Enum.sum()
    end)
  end
end
