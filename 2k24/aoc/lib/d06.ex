defmodule D06 do
  @gard "^"
  @obstacle "#"

  def p1 do
    map =
      Parser.parse("inputs/d06_sample.txt")
      |> then(&Parser.as_map/1)

    patrol(map, find_gard(map)) |> MapSet.size()
  end

  def p2 do
    map =
      Parser.parse("inputs/d06.txt")
      |> then(&Parser.as_map/1)

    gard_position = find_gard(map)

    obstacles =
      for y <- 0..(map_size(map) - 1),
          x <- 0..(map_size(map[y]) - 1),
          {y, x} != gard_position and map[y][x] != @obstacle,
          do: {y, x}

    obstacles
    |> Task.async_stream(
      fn {y, x} ->
        if Map.put(map, y, Map.put(map[y], x, @obstacle)) |> loops?(gard_position),
          do: 1,
          else: 0
      end,
      max_concurrency: 1000
    )
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  defp loops?(map, guard_position) do
    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while({guard_position, :up, MapSet.new()}, fn _step, {pos, dir, visited} ->
      visited = MapSet.put(visited, {pos, dir})
      next_position = move(pos, dir)

      case {visit(next_position, map), MapSet.member?(visited, {next_position, dir})} do
        {_, true} ->
          {:halt, true}

        {nil, _} ->
          {:halt, false}

        {@obstacle, _} ->
          {:cont, {pos, turn(dir), visited}}

        _ ->
          {:cont, {next_position, dir, visited}}
      end
    end)
  end

  defp patrol(map, guard_position) do
    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while({guard_position, :up, MapSet.new()}, fn _step, {pos, dir, visited} ->
      visited = MapSet.put(visited, pos)
      next_position = move(pos, dir)

      case visit(next_position, map) do
        nil ->
          {:halt, visited}

        @obstacle ->
          {:cont, {pos, turn(dir), visited}}

        _ ->
          {:cont, {next_position, dir, visited}}
      end
    end)
  end

  defp visit({y, x}, map), do: map[y][x]

  defp turn(:up), do: :right
  defp turn(:right), do: :down
  defp turn(:down), do: :left
  defp turn(:left), do: :up

  defp move({y, x}, :up), do: {y - 1, x}
  defp move({y, x}, :down), do: {y + 1, x}
  defp move({y, x}, :left), do: {y, x - 1}
  defp move({y, x}, :right), do: {y, x + 1}

  defp find_gard(map) do
    map
    |> Enum.find_value(fn {y, v} ->
      case Enum.find(v, fn {_, vv} -> vv == @gard end) do
        nil -> nil
        {x, _} -> {y, x}
      end
    end)
  end
end
