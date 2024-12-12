defmodule D02 do
  def p1 do
    Parser.parse("inputs/d02.txt")
    |> Parser.into_integer_values()
    |> Enum.filter(&safe?(&1))
    |> Enum.count()
  end

  def p2 do
    Parser.parse("inputs/d2.txt")
    |> Parser.into_integer_values()
    |> Enum.filter(&safe?(&1, :tolerance))
    |> Enum.count()
  end

  defp safe?(l) do
    differences = l |> Enum.chunk_every(2, 1, :discard) |> Enum.map(fn [a, b] -> a - b end)

    Enum.all?(differences, &(&1 in 1..3)) || Enum.all?(differences, &(&1 in -1..-3//-1))
  end

  defp safe?(l, :tolerance) do
    0..(length(l) - 1)
    |> Enum.map(&List.delete_at(l, &1))
    |> Enum.any?(&safe?/1)
  end
end
