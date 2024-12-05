defmodule D05 do
  def p1 do
    [rules, updates] = parse()

    updates
    |> Enum.filter(&valid?(&1, rules))
    |> Enum.map(&middle/1)
    |> Enum.sum()
  end

  def p2 do
    [rules, updates] = parse()

    updates
    |> Enum.filter(&invalid?(&1, rules))
    |> Enum.map(
      &Enum.sort(&1, fn a, b ->
        valid?([a, b], rules)
      end)
    )
    |> Enum.map(&middle/1)
    |> Enum.sum()
  end

  def invalid?(update, rules) do
    not valid?(update, rules)
  end

  def valid?(update, rules) do
    update
    |> Enum.with_index()
    |> Enum.all?(fn {page, index} ->
      not Enum.any?(
        Enum.slice(update, 0..index),
        &MapSet.member?(rules[page] || MapSet.new(), &1)
      )
    end)
  end

  defp middle(update) do
    Enum.at(update, div(length(update), 2))
  end

  defp parse() do
    [raw_rules, raw_updates] = Parser.parse("inputs/d05.txt", "\n\n")

    rules =
      raw_rules
      |> String.split("\n")
      |> Enum.reduce(%{}, fn item, acc ->
        [before, aftr] = String.split(item, "|") |> Enum.map(&String.to_integer/1)

        Map.update(acc, before, MapSet.new([aftr]), fn map ->
          MapSet.put(map, aftr)
        end)
      end)

    updates =
      raw_updates
      |> String.split("\n")
      |> Enum.map(&String.split(&1, ","))
      |> Enum.map(&Enum.map(&1, fn v -> String.to_integer(v) end))

    [rules, updates]
  end
end
