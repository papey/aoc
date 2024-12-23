defmodule D12 do
  @directions [{0, 1}, {1, 0}, {0, -1}, {-1, 0}]

  def p1 do
    map =
      Parser.parse("inputs/d12.txt")
      |> Parser.as_map()

    discover(map)
    |> Enum.map(fn {id, set} ->
      label = String.split(id, "_") |> List.first()

      perimeter =
        Enum.reduce(set, 0, fn {y, x}, acc ->
          acc +
            Enum.count(@directions, fn {dy, dx} -> map[y + dy][x + dx] != label end)
        end)

      MapSet.size(set) * perimeter
    end)
    |> Enum.sum()
  end

  def p2 do
    map =
      Parser.parse("inputs/d12.txt")
      |> Parser.as_map()

    discover(map)
    |> Enum.map(fn {_, set} ->
      sides =
        Enum.reduce(set, 0, fn {y, x}, acc ->
          current = map[y][x]

          neighbors = %{
            left: map[y][x - 1],
            right: map[y][x + 1],
            top: map[y - 1][x],
            top_left: map[y - 1][x - 1],
            top_right: map[y - 1][x + 1],
            bottom: map[y + 1][x],
            bottom_left: map[y + 1][x - 1],
            bottom_right: map[y + 1][x + 1]
          }

          corners = [
            (neighbors.top != current && neighbors.left != current) ||
              (neighbors.top_left != current && neighbors.left == current &&
                 neighbors.top == current),
            (neighbors.top != current && neighbors.right != current) ||
              (neighbors.top_right != current && neighbors.right == current &&
                 neighbors.top == current),
            (neighbors.bottom != current && neighbors.left != current) ||
              (neighbors.bottom_left != current && neighbors.left == current &&
                 neighbors.bottom == current),
            (neighbors.bottom != current && neighbors.right != current) ||
              (neighbors.bottom_right != current && neighbors.right == current &&
                 neighbors.bottom == current)
          ]

          acc + Enum.count(corners, & &1)
        end)

      MapSet.size(set) * sides
    end)
    |> Enum.sum()
  end

  defp discover(map) do
    discover(map, %{}, MapSet.new()) |> elem(0)
  end

  defp discover(map, areas, visited) do
    h = map_size(map)
    l = map_size(map[0])

    Enum.reduce(0..(h - 1), {areas, visited}, fn y, {areas, visited} ->
      Enum.reduce(0..(l - 1), {areas, visited}, fn x, {areas, visited} ->
        id = map[y][x] <> "_#{y}_#{x}"
        discover(map, {y, x}, id, areas, visited)
      end)
    end)
  end

  defp discover(map, point = {y, x}, id, areas, visited) do
    if MapSet.member?(visited, point) do
      {areas, visited}
    else
      visited = MapSet.put(visited, point)
      label = map[y][x]

      areas =
        Map.update(areas, id, MapSet.new([point]), fn set -> MapSet.put(set, point) end)

      @directions
      |> Enum.filter(fn {dy, dx} ->
        map[y + dy][x + dx] != nil && map[y + dy][x + dx] == label
      end)
      |> Enum.map(fn {dy, dx} -> {y + dy, x + dx} end)
      |> Enum.reduce({areas, visited}, fn pos, {areas, visited} ->
        discover(map, pos, id, areas, visited)
      end)
    end
  end
end
