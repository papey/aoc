defmodule Parser do
  def parse(filename, by \\ "\n") do
    File.read!(filename)
    |> String.split(by, trim: true)
    |> Enum.map(&String.trim/1)
  end

  def into_integer_values(inputs) do
    inputs
    |> Enum.map(&String.split(&1, "\s"))
    |> Enum.map(fn values -> Enum.map(values, &String.to_integer/1) end)
  end
end
