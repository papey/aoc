defmodule D04 do
  def p1 do
    Parser.parse("inputs/d04.txt")
    |> then(&Parser.as_map/1)
    |> then(&count_xmas/1)
  end

  def p2 do
    Parser.parse("inputs/d04.txt")
    |> then(&Parser.as_map/1)
    |> then(&count_Xmas/1)
  end

  defp count_Xmas(map) do
    Enum.reduce(map, 0, fn {y, l}, acc ->
      Enum.reduce(l, acc, fn
        {x, "A"}, nested_acc -> nested_acc + find_Xmas(map, y, x)
        _, nested_acc -> nested_acc
      end)
    end)
  end

  @mas MapSet.new(["M", "A", "S"])

  defp find_Xmas(map, y, x) do
    diagonals = [
      [map[y - 1][x - 1], map[y][x], map[y + 1][x + 1]],
      [map[y + 1][x - 1], map[y][x], map[y - 1][x + 1]]
    ]

    if Enum.all?(diagonals, fn d -> MapSet.equal?(@mas, MapSet.new(d)) end), do: 1, else: 0
  end

  defp count_xmas(map) do
    Enum.reduce(map, 0, fn {y, l}, acc ->
      Enum.reduce(l, acc, fn
        {x, "X"}, nested_acc -> nested_acc + find_xmas(map, y, x)
        _, nested_acc -> nested_acc
      end)
    end)
  end

  @dirs [{-1, 0}, {1, 0}, {0, -1}, {0, 1}, {-1, -1}, {-1, 1}, {1, -1}, {1, 1}]

  defp find_xmas(map, y, x) do
    Enum.reduce(@dirs, 0, fn {dy, dx}, acc ->
      case 1..3 |> Enum.map(fn n -> map[y + n * dy][x + n * dx] end) do
        ["M", "A", "S"] -> acc + 1
        _ -> acc
      end
    end)
  end
end
