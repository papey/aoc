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
    Enum.reduce(instructions, {%{}, {0, 0}}, fn inst, {mem, {or_mask, and_mask} = masks} ->
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
    Enum.reduce(instructions, {%{}, {0, 0}}, fn inst, {mem, {or_mask, and_mask} = masks} ->
      if String.contains?(inst, "mask") do
        {mem, parse_mask(inst)}
      else
        [addr, value] =
          Regex.run(@mem_regex, inst)
          |> tl()
          |> Enum.map(&String.to_integer/1)

        # a submask where every X is replaced with a 1 to help identify floating bits
        fbits = ~~~or_mask &&& and_mask

        # apply the mask using an or, as specified in the challenge
        # and_mask &&& ~~~fbits is computes the mask and the ||| (bitwise or) applies it
        addrs = permutations(addr ||| (and_mask &&& ~~~fbits), fbits)

        # Put value in all addresses
        {Enum.reduce(addrs, mem, fn addr, acc ->
           Map.put(acc, addr, value)
         end), masks}
      end
    end)
  end

  def permutations(base, fbits) do
    permutations(base, fbits, 64)
  end

  # the recursion halts when there is no more floating bits to check
  def permutations(addr, _fbits, shift) when shift < 0 do
    [addr]
  end

  # while there is floating bits
  def permutations(addr, fbits, shift) do
    # check if current bit is a floating one
    if (fbits &&& 1 <<< shift) >>> shift == 1 do
      # and_mask is like setting the current floating bit to 0
      and_mask = (1 <<< 65) - 1 - (1 <<< shift)
      # or_mask is like setting the current floating bit to 1
      or_mask = 1 <<< shift

      # the recursive call collects all sub solutions
      permutations(addr &&& and_mask, fbits, shift - 1) ++
        permutations(addr ||| or_mask, fbits, shift - 1)
    else
      permutations(addr, fbits, shift - 1)
    end
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
