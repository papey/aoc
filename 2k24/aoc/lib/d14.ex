defmodule D14 do
  @regex ~r/p=([+-]?\d+),([+-]?\d+) v=([+-]?\d+),([+-]?\d+)/

  @wide 101
  @tall 103
  @steps 100

  def p1 do
    Parser.parse("inputs/d14.txt")
    |> Enum.map(fn line ->
      [x, y, vx, vy] =
        Regex.scan(@regex, line) |> Enum.at(0) |> tl() |> Enum.map(&String.to_integer/1)

      simulate(x, y, vx, vy, @steps)
    end)
    |> safety_factor()
  end

  def p2 do
    robots =
      Parser.parse("inputs/d14.txt")
      |> Enum.map(fn line ->
        [x, y, vx, vy] =
          Regex.scan(@regex, line) |> Enum.at(0) |> tl() |> Enum.map(&String.to_integer/1)

        {{x, y}, {vx, vy}}
      end)

    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while(0, fn steps, _ ->
      no_shared_tiles? =
        robots
        |> Enum.map(fn {{x, y}, {vx, vy}} -> simulate(x, y, vx, vy, steps) end)
        |> Enum.frequencies()
        |> Enum.all?(fn {_, count} -> count == 1 end)

      if no_shared_tiles? do
        {:halt, steps}
      else
        {:cont, steps}
      end
    end)
  end

  def simulate(x, y, vx, vy, steps),
    do: {Integer.mod(x + vx * steps, @wide), Integer.mod(y + vy * steps, @tall)}

  defp safety_factor(robots) do
    mx = div(@wide, 2)
    my = div(@tall, 2)

    robots
    |> Enum.reduce([0, 0, 0, 0], fn {x, y}, [z1, z2, z3, z4] ->
      case {x, y} do
        {x, y} when x < mx and y < my ->
          [z1 + 1, z2, z3, z4]

        {x, y} when x < mx and y > my ->
          [z1, z2 + 1, z3, z4]

        {x, y} when x > mx and y < my ->
          [z1, z2, z3 + 1, z4]

        {x, y} when x > mx and y > my ->
          [z1, z2, z3, z4 + 1]

        _ ->
          [z1, z2, z3, z4]
      end
    end)
    |> Enum.reduce(1, &Kernel.*/2)
  end
end
