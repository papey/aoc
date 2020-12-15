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

defmodule AOC.D15 do
  import AOC.Helper.Input

  def run1(test \\ false) do
    {_state, last_spoken} =
      get_input("D15", test)
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.reduce({%{}, 0}, fn {v, turn}, {state, _last} ->
        {Map.put(state, v, {:none, turn + 1}), v}
      end)
      |> find_last_spoken(2020)

    last_spoken
  end

  def run2(test \\ false) do
    {_state, last_spoken} =
      get_input("D15", test)
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.reduce({%{}, 0}, fn {v, turn}, {state, _last} ->
        {Map.put(state, v, {:none, turn + 1}), v}
      end)
      |> find_last_spoken(30_000_000)

    last_spoken
  end

  def find_last_spoken({history, _last_spoken} = initial_state, turns) do
    Enum.reduce((map_size(history) + 1)..turns, initial_state, fn turn, {history, last_spoken} ->
      case Map.get(history, last_spoken) do
        {:none, _} ->
          {_, previous_turn} = Map.get(history, 0)
          {Map.put(history, 0, {previous_turn, turn}), 0}

        {pre_previous_turn, previous_turn} ->
          next_value = previous_turn - pre_previous_turn

          new_state =
            case Map.get(history, next_value) do
              {_, previous_turn_in_history} ->
                Map.put(
                  history,
                  next_value,
                  {previous_turn_in_history, turn}
                )

              _ ->
                Map.put(history, next_value, {:none, turn})
            end

          {new_state, next_value}

        _ ->
          {_, previous} = Map.get(history, 0)

          new_state =
            Map.put(history, last_spoken, {:none, turn - 1})
            |> Map.put(0, {previous, turn})

          {new_state, 0}
      end
    end)
  end
end
