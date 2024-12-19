defmodule D19 do
  @possible_patterns_table :possible_patterns
  @combinations_patterns_table :combinations_patterns

  def p1 do
    ensure_cache(@possible_patterns_table)

    {towel_patterns, designs} = parse()

    designs
    |> Task.async_stream(&possible?(&1, towel_patterns))
    |> Enum.filter(&elem(&1, 1))
    |> Enum.count()
  end

  def p2 do
    ensure_cache(@combinations_patterns_table)

    {towel_patterns, designs} = parse()

    designs
    |> Task.async_stream(&combinations(&1, towel_patterns))
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  defp parse do
    [raw_towel_patterns, raw_designs] = Parser.parse("inputs/d19.txt", "\n\n")

    towel_patterns = raw_towel_patterns |> String.split(",") |> Enum.map(&String.trim/1)
    designs = raw_designs |> String.split("\n")

    {towel_patterns, designs}
  end

  defp ensure_cache(table) do
    if :ets.info(table) == :undefined do
      :ets.new(table, [:set, :public, :named_table])
    end
  end

  defp possible?("", _), do: true

  defp possible?(design, towel_patterns) do
    case :ets.lookup(@possible_patterns_table, design) do
      [{^design, result}] ->
        result

      [] ->
        Enum.any?(towel_patterns, fn pattern ->
          if String.starts_with?(design, pattern) do
            String.replace_prefix(design, pattern, "") |> possible?(towel_patterns)
          end
        end)
        |> tap(fn result ->
          :ets.insert(@possible_patterns_table, {design, result})
        end)
    end
  end

  defp combinations("", _), do: 1

  defp combinations(design, towel_patterns) do
    towel_patterns
    |> Enum.filter(fn pattern -> String.starts_with?(design, pattern) end)
    |> Enum.map(fn pattern -> String.replace_prefix(design, pattern, "") end)
    |> Enum.map(fn design ->
      case :ets.lookup(@combinations_patterns_table, design) do
        [{^design, result}] ->
          result

        [] ->
          combinations(design, towel_patterns)
          |> tap(fn result -> :ets.insert(@combinations_patterns_table, {design, result}) end)
      end
    end)
    |> Enum.sum()
  end
end
