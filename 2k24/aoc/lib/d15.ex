defmodule D15 do
  @robot "@"
  @wall "#"
  @empty "."
  @box "O"
  @lbox "["
  @rbox "]"

  @dirs %{
    "^" => {-1, 0},
    "v" => {1, 0},
    "<" => {0, -1},
    ">" => {0, 1}
  }

  def p1 do
    [raw_map, raw_dirs] = Parser.parse("inputs/d15.txt", "\n\n")
    {map, dirs, robot} = parse(raw_map, raw_dirs)

    dirs
    |> Enum.reduce({map, robot}, fn dir, {map, robot} ->
      move(map, robot, dir)
    end)
    |> elem(0)
    |> box_coordinates(@box)
    |> Enum.map(&gps_coordinate/1)
    |> Enum.sum()
  end

  def p2 do
    [raw_map, raw_dirs] = Parser.parse("inputs/d15.txt", "\n\n")

    twiced =
      [[@box, "[]"], [@wall, "##"], [@empty, ".."], [@robot, "@."]]
      |> Enum.reduce(raw_map, fn [from, to], map ->
        String.replace(map, from, to)
      end)

    {map, dirs, robot} = parse(twiced, raw_dirs)

    dirs
    |> Enum.reduce({map, robot}, fn dir, {map, robot} ->
      # it's like move but wiider 🤷‍♀️
      moove(map, robot, dir)
    end)
    |> elem(0)
    |> box_coordinates(@lbox)
    |> Enum.map(&gps_coordinate/1)
    |> Enum.sum()
  end

  defp box_coordinates(map, symbol) do
    Enum.reduce(map, [], fn {y, row}, acc ->
      Enum.reduce(row, acc, fn {x, cell}, acc ->
        if cell == symbol, do: [{y, x} | acc], else: acc
      end)
    end)
  end

  defp gps_coordinate({y, x}), do: y * 100 + x

  defp check_boxes(map, impacted, {y, x}, dy) do
    if MapSet.member?(impacted, {y, x}) do
      {false, impacted}
    else
      case Map.get(map, y) |> Map.get(x) do
        @lbox ->
          impacted = MapSet.put(impacted, {y, x})
          {stuck2, impacted} = check_boxes(map, impacted, {y, x + 1}, dy)
          {stuck1, impacted} = check_boxes(map, impacted, {y + dy, x}, dy)

          {stuck1 or stuck2, impacted}

        @rbox ->
          impacted = MapSet.put(impacted, {y, x})
          {stuck2, impacted} = check_boxes(map, impacted, {y, x - 1}, dy)
          {stuck1, impacted} = check_boxes(map, impacted, {y + dy, x}, dy)

          {stuck1 or stuck2, impacted}

        @empty ->
          {false, impacted}

        @wall ->
          {true, MapSet.new()}
      end
    end
  end

  defp moove(map, {y, x}, {dy, dx}) do
    {stuck?, impacted} =
      Stream.iterate(1, &(&1 + 1))
      |> Stream.map(fn n -> {y + n * dy, x + n * dx} end)
      |> Enum.reduce_while({false, MapSet.new()}, fn {ny, nx}, {_, impacted} ->
        case Map.get(map, ny) |> Map.get(nx) do
          @wall ->
            {:halt, {true, impacted}}

          cell when cell in [@lbox, @rbox] ->
            case {dy, dx} do
              {0, _} ->
                {:cont, {false, MapSet.put(impacted, {ny, nx})}}

              {_, 0} ->
                {:halt, check_boxes(map, MapSet.new(), {ny, nx}, dy)}
            end

          @empty ->
            {:halt, {false, impacted}}

          _ ->
            {:halt, {true, impacted}}
        end
      end)

    if stuck? do
      {map, {y, x}}
    else
      origin = for {y, x} <- impacted, into: %{}, do: {{y, x}, map[y][x]}

      reset =
        Enum.reduce(impacted, map, fn {y, x}, map ->
          put_in(map, [y, x], @empty)
        end)

      updated =
        Enum.reduce(impacted, reset, fn {y, x}, map ->
          map
          |> put_in([y, x], @empty)
          |> put_in([y + dy, x + dx], Map.get(origin, {y, x}))
        end)
        |> put_in([y + dy, x + dx], @robot)
        |> put_in([y, x], @empty)

      {updated, {y + dy, x + dx}}
    end
  end

  defp move(map, {y, x}, {dy, dx}) do
    {stuck?, {ny, nx}} =
      Stream.iterate(1, &(&1 + 1))
      |> Stream.map(fn n -> {y + n * dy, x + n * dx} end)
      |> Enum.reduce_while(nil, fn {ny, nx}, _ ->
        case Map.get(map, ny) |> Map.get(nx) do
          @wall -> {:halt, {true, {ny, nx}}}
          @box -> {:cont, {false, {ny, nx}}}
          @empty -> {:halt, {false, {ny, nx}}}
          _ -> {:halt, {true, {ny, nx}}}
        end
      end)

    if stuck? do
      {map, {y, x}}
    else
      {map
       |> put_in([y, x], @empty)
       |> put_in([ny, nx], @box)
       |> put_in([y + dy, x + dx], @robot), {y + dy, x + dx}}
    end
  end

  defp parse(raw_map, raw_dirs) do
    map = raw_map |> String.split("\n") |> Parser.as_map()
    dirs = raw_dirs |> String.replace("\n", "") |> String.graphemes() |> Enum.map(&@dirs[&1])

    {ry, rx} =
      Enum.find_value(map, fn {y, row} ->
        Enum.find_value(row, fn {x, cell} ->
          if cell == @robot, do: {y, x}, else: nil
        end)
      end)

    {map, dirs, {ry, rx}}
  end
end
