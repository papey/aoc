defmodule D10 do
  @uphill 1
  @start 0
  @ends 9
  @dirs [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]

  def p1 do
    map =
      Parser.parse("inputs/d10.txt")
      |> then(&Parser.as_map/1)
      |> then(&to_heights/1)

    map
    |> starts()
    |> Enum.map(fn pos ->
      hike(pos, map)
      |> Enum.uniq()
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  def p2 do
    map =
      Parser.parse("inputs/d10.txt")
      |> then(&Parser.as_map/1)
      |> then(&to_heights/1)

    map
    |> starts()
    |> Enum.map(fn pos ->
      hike(pos, map)
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  defp hike(position, map), do: hike(position, map, 0)

  defp hike(pos, _, @ends), do: [pos]

  defp hike({y, x}, map, height) do
    neighbors({y, x})
    |> Enum.filter(&even_gradual_slope?(&1, {y, x}, map))
    |> Enum.reduce([], fn {ny, nx}, paths -> paths ++ hike({ny, nx}, map, height + @uphill) end)
  end

  defp neighbors({y, x}), do: Enum.map(@dirs, fn {dy, dx} -> {y + dy, x + dx} end)

  defp even_gradual_slope?({ny, nx}, {y, x}, map), do: map[y][x] + 1 == map[ny][nx]

  defp to_heights(map) do
    Enum.map(map, fn {y, l} ->
      {y,
       Enum.map(l, fn
         {x, "."} -> {x, "."}
         {x, c} -> {x, String.to_integer(c)}
       end)
       |> Map.new()}
    end)
    |> Map.new()
  end

  defp starts(map) do
    Enum.reduce(map, [], fn {y, l}, acc ->
      Enum.reduce(l, acc, fn
        {x, @start}, inner_acc -> [{y, x} | inner_acc]
        _, inner_acc -> inner_acc
      end)
    end)
  end
end
