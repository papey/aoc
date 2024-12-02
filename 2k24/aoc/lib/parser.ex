defmodule Parser do
  def parse(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
  end

  def into_integer_values(inputs) do
    inputs
    |> Enum.map(&String.split(&1, "\s"))
    |> Enum.map(fn values -> Enum.map(values, &String.to_integer/1) end)
  end
end
