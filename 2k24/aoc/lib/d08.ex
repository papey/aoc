defmodule D08 do
  def p1 do
    map =
      Parser.parse("inputs/d08.txt")
      |> then(&Parser.as_map/1)

    {h, l} = size(map)

    for {_id, coords} <- find_antennas(map),
        {ya, xa} <- coords,
        {yb, xb} <- coords,
        {ya, xa} != {yb, xb},
        {cy, cx} = {ya + ya - yb, xa + xa - xb},
        cy >= 0 and cx >= 0 and cy < h and cx < l,
        into: MapSet.new() do
      {cy, cx}
    end
    |> MapSet.size()
  end

  def p2 do
    map =
      Parser.parse("inputs/d08.txt")
      |> then(&Parser.as_map/1)

    h = map_size(map)
    l = map_size(map[0])
    diagonal = :math.sqrt(l * l + h * h) |> round()

    for {_id, coords} <- find_antennas(map),
        {ya, xa} <- coords,
        {yb, xb} <- coords,
        {dy, dx} = {ya - yb, xa - xb},
        n <- 1..diagonal,
        {cy, cx} = {ya + n * dy, xa + n * dx},
        cy >= 0 and cx >= 0 and cy < h and cx < l,
        into: MapSet.new() do
      {cy, cx}
    end
    |> MapSet.size()
  end

  defp find_antennas(map) do
    Enum.reduce(map, Map.new(), fn {y, l}, antennas ->
      Enum.reduce(l, antennas, fn
        {_, "."}, acc -> acc
        {x, id}, acc -> Map.update(acc, id, [{y, x}], &(&1 ++ [{y, x}]))
      end)
    end)
  end

  defp size(map) do
    {map_size(map), map_size(map[0])}
  end
end
