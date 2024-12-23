defmodule D22 do
  import Bitwise

  @pruner 16_777_216

  def p1 do
    Parser.parse("inputs/d22.txt")
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&Enum.reduce(1..2000//1, &1, fn _, seed -> evolve(seed) end))
    |> Enum.sum()
  end

  def p2 do
    Parser.parse("inputs/d22.txt")
    |> Enum.map(&String.to_integer/1)
    |> Task.async_stream(fn seed ->
      Enum.map_reduce(1..2000//1, seed, fn _, seed ->
        ev = evolve(seed)
        {Integer.digits(ev) |> List.last(), ev}
      end)
      |> elem(0)
      |> Enum.chunk_every(5, 1, :discard)
      |> Enum.reduce(%{}, fn seq, acc ->
        deltas = Enum.chunk_every(seq, 2, 1, :discard) |> Enum.map(fn [v1, v2] -> v2 - v1 end)
        Map.put_new(acc, deltas, List.last(seq))
      end)
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.reduce(%{}, fn map, acc ->
      Map.merge(acc, map, fn _key, v1, v2 -> v1 + v2 end)
    end)
    |> Enum.max_by(&elem(&1, 1))
    |> elem(1)
  end

  def evolve(secret) do
    s1 = secret |> Kernel.*(64) |> mix(secret) |> prune()

    s2 = s1 |> Kernel./(32) |> floor() |> mix(s1) |> prune()

    s2 |> Kernel.*(2048) |> mix(s2) |> prune()
  end

  def mix(value, secret) do
    bxor(secret, value)
  end

  def prune(secret) do
    rem(secret, @pruner)
  end
end
