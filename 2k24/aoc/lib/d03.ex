defmodule D03 do
  @operation_regex ~r/mul\((\d+),(\d+)\)|do\(\)|don't\(\)/

  def p1 do
    Parser.parse("inputs/d03.txt")
    |> Enum.join("\n")
    |> then(&Regex.scan(@operation_regex, &1, capture: :all))
    |> Enum.map(fn match ->
      case match do
        [_, n1, n2] -> String.to_integer(n1) * String.to_integer(n2)
        _ -> 0
      end
    end)
    |> Enum.sum()
  end

  def p2 do
    Parser.parse("inputs/d03.txt")
    |> Enum.join("\n")
    |> then(&Regex.scan(@operation_regex, &1, capture: :all))
    |> Enum.reduce([:do, 0], fn input, [status, sum] ->
      case [input, status] do
        [["do()"], _] -> [:do, sum]
        [["don't()"], _] -> [:dont, sum]
        [[_, n1, n2], :do] -> [:do, String.to_integer(n1) * String.to_integer(n2) + sum]
        _ -> [:dont, sum]
      end
    end)
    |> Enum.at(1)
  end
end
