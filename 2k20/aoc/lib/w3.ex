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

  def init(instructions, :values) do
    Enum.reduce(instructions, {%{}, {0, 0}}, fn inst, {mem, masks} ->
      if String.contains?(inst, "mask") do
        {mem, parse_mask(inst)}
      else
        [addr, value] =
          Regex.run(@mem_regex, inst)
          |> tl()
          |> Enum.map(&String.to_integer/1)

        {Map.put(mem, addr, apply_masks(value, masks)), masks}
      end
    end)
  end

      if String.contains?(inst, "mask") do
        {mem, parse_mask(inst)}
      else
        [addr, value] =
          Regex.run(@mem_regex, inst)
          |> tl()
          |> Enum.map(&String.to_integer/1)

        {Map.put(mem, addr, apply_masks(value, masks)), masks}
      end
    end)
  end

  def apply_masks(value, {or_mask, and_mask}) do
    (value ||| or_mask) &&& and_mask
  end

  def parse_mask(mask) do
    "mask = " <> m = mask

    gm =
      String.graphemes(m)
      |> Enum.reverse()
      |> Enum.with_index()

    {reduce_mask(gm, :or), reduce_mask(gm, :and)}
  end

  def reduce_mask(mask_indexed, kind) do
    Enum.reduce(mask_indexed, 0, fn {v, idx}, acc ->
      if v == "X" do
        case kind do
          :or ->
            acc ||| 0 <<< idx

          :and ->
            acc ||| 1 <<< idx
        end
      else
        acc ||| String.to_integer(v) <<< idx
      end
    end)
  end
end
