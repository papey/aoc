defmodule AOC.D14 do
  import AOC.Helper.Input
  use Bitwise

  @mem_regex ~r/mem\[(\d+)\] = (\d+)/

  def run1(test \\ false) do
    get_input("D14", test)
    |> split_input()
    |> init(:values)
    |> (fn {mem, _} -> mem end).()
    |> Enum.reduce(0, fn {_k, v}, acc -> acc + v end)
  end

  def run2(test \\ false) do
    get_input("D14", test)
    |> split_input()
    |> init(:memory)
    |> (fn {mem, _} -> mem end).()
    |> Enum.reduce(0, fn {_k, v}, acc -> acc + v end)
  end

  def init(instructions, :values) do
    Enum.reduce(instructions, {%{}, {0, 0, []}}, fn inst, {mem, {or_mask, and_mask, _} = masks} ->
      if String.contains?(inst, "mask") do
        {mem, parse_mask(inst)}
      else
        [addr, value] =
          Regex.run(@mem_regex, inst)
          |> tl()
          |> Enum.map(&String.to_integer/1)

        {Map.put(mem, addr, (value ||| or_mask) &&& and_mask), masks}
      end
    end)
  end

  def init(instructions, :memory) do
    Enum.reduce(instructions, {%{}, {0, 0, []}}, fn
      inst, {mem, {or_mask, and_mask, floatings} = masks} ->
        if String.contains?(inst, "mask") do
          {mem, parse_mask(inst)}
        else
          [addr, value] =
            Regex.run(@mem_regex, inst)
            |> tl()
            |> Enum.map(&String.to_integer/1)

          # a value where bits sets to one represent floating bits
          fbits = ~~~or_mask &&& and_mask

          # apply the mask from part 2 description, then compute permutations
          addrs = permutations(addr ||| (and_mask &&& ~~~fbits), floatings)

          # Put value in all addresses
          {Enum.reduce(addrs, mem, fn addr, acc ->
             Map.put(acc, addr, value)
           end), masks}
        end
    end)
  end

  def permutations(addr, []), do: [addr]

  def permutations(addr, [cur | rest]) do
    permutations(addr &&& (1 <<< 65) - 1 - (1 <<< cur), rest) ++
      permutations(addr ||| 1 <<< cur, rest)
  end

  def parse_mask("mask = " <> m) do
    String.graphemes(m)
    |> Enum.reverse()
    |> Enum.with_index()
    |> reduce_mask()
  end

  def reduce_mask(mask_indexed) do
    Enum.reduce(mask_indexed, {0, 0, []}, fn {v, idx}, {or_mask, and_mask, floating} ->
      if v == "X" do
        {or_mask ||| 0 <<< idx, and_mask ||| 1 <<< idx, [idx | floating]}
      else
        shifted = String.to_integer(v) <<< idx
        {or_mask ||| shifted, and_mask ||| shifted, floating}
      end
    end)
  end
end
