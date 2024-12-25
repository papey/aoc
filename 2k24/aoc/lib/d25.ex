defmodule D25 do
  def p1 do
    {locks, keys} =
      Parser.parse("inputs/d25.txt", "\n\n")
      |> Enum.map(&String.split(&1, "\n"))
      |> Enum.map(fn entry ->
        Enum.map(entry, fn line ->
          line |> String.graphemes() |> Enum.map(fn v -> if v == "#", do: 1, else: 0 end)
        end)
      end)
      |> Enum.split_with(fn entry -> entry |> List.first() |> Enum.count(&(&1 == 1)) == 5 end)

    locks
    |> Task.async_stream(fn lock ->
      keys
      |> Enum.filter(fn key ->
        key
        |> Stream.zip(lock)
        |> Enum.all?(fn {k, l} ->
          Stream.zip(k, l)
          |> Enum.all?(fn couple ->
            couple != {1, 1}
          end)
        end)
      end)
      |> Enum.count()
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end
end
