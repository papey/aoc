defmodule Parser do
  def parse(filename, by \\ "\n") do
    File.read!(filename)
    |> String.split(by, trim: true)
    |> Enum.map(&String.trim/1)
  end

  def as_map(input) do
    input
    |> Enum.with_index()
    |> Enum.into(%{}, fn {l, y} ->
      {y,
       l
       |> String.split("", trim: true)
       |> Enum.with_index()
       |> Enum.into(%{}, fn {char, x} -> {x, char} end)}
    end)
    |> Map.new()
  end

  def into_integer_values(inputs) do
    inputs
    |> Enum.map(&String.split(&1, "\s"))
    |> Enum.map(fn values -> Enum.map(values, &String.to_integer/1) end)
  end
end
