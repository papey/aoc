defmodule D07 do
  def p1 do
    Parser.parse("inputs/d07.txt")
    |> then(&extract/1)
    |> Enum.filter(fn [test | numbers] ->
      calibrated?(test, numbers)
    end)
    |> Enum.map(fn [test | _] -> test end)
    |> Enum.sum()
  end

  def p2 do
    Parser.parse("inputs/d07.txt")
    |> then(&extract/1)
    |> Enum.filter(fn [test | numbers] ->
      calibrated?(test, numbers, true)
    end)
    |> Enum.map(fn [test | _] -> test end)
    |> Enum.sum()
  end

  defp calibrated?(test, numbers, concat \\ false), do: calibrated?(test, numbers, concat, 0)
  defp calibrated?(test, _, _, candidate) when candidate > test, do: false
  defp calibrated?(test, [], _, candidate) when test == candidate, do: true
  defp calibrated?(_, [], _, _), do: false

  defp calibrated?(test, [number | numbers], concat, candidate) do
    calibrated?(test, numbers, concat, candidate + number) ||
      calibrated?(test, numbers, concat, candidate * number) ||
      (concat && calibrated?(test, numbers, concat, concat(candidate, number)))
  end

  def concat(a, b), do: String.to_integer(Integer.to_string(a) <> Integer.to_string(b))

  defp extract(input) do
    input
    |> Enum.map(&String.replace(&1, ":", ""))
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(&Enum.map(&1, fn v -> String.to_integer(v) end))
  end
end
