# A*Ax + B*Bx = Rx
# A*Ay + B*By = Ry

# B = (Ry-A*Ay)/Ry
# A = (Rx - Ry*Bx/By)/(Ax - Ay*Bx/By)

defmodule D13 do
  def p1 do
    Parser.parse("inputs/d13.txt", "\n\n")
    |> Enum.map(&String.replace(&1, "\n", ";"))
    |> Enum.map(fn group ->
      Regex.scan(~r/\d+/, group) |> List.flatten() |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.map(&cost(&1))
    |> Enum.sum()
  end

  def p2 do
    delta = 10_000_000_000_000

    Parser.parse("inputs/d13.txt", "\n\n")
    |> Enum.map(&String.replace(&1, "\n", ";"))
    |> Enum.map(fn group ->
      [ax, ay, bx, by, rx, ry] =
        Regex.scan(~r/\d+/, group) |> List.flatten() |> Enum.map(&String.to_integer/1)

      [ax, ay, bx, by, rx + delta, ry + delta]
    end)
    |> Enum.map(&cost(&1))
    |> Enum.sum()
  end

  defp cost([ax, ay, bx, by, rx, ry]) do
    a = ((rx - ry * bx / by) / (ax - ay * bx / by)) |> round
    b = ((ry - a * ay) / by) |> round

    if a >= 0 && b >= 0 && a * ax + b * bx == rx && a * ay + b * by == ry do
      a * 3 + b
    else
      0
    end
  end
end
