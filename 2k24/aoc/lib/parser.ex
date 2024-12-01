defmodule Parser do
  def parse(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
  end
end
