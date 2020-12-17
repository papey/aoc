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

defmodule AOC.D16 do
  import AOC.Helper.Input

  @rules_regex ~r/^([a-z ]+): (\d+)-(\d+) or (\d+)-(\d+)/

  def run1(test \\ false) do
    [raw_rules, _raw_my, raw_nearby] =
      get_input("D16", test)
      |> String.split("\n\n", trim: true)

    rules = parse_rules(raw_rules)

    parse_tickets(raw_nearby)
    |> Enum.reduce(0, fn t, acc ->
      acc + scanning_error(t, rules)
    end)
  end

  def run2(test \\ false) do
    [raw_rules, raw_my, raw_nearby] =
      get_input("D16", test)
      |> String.split("\n\n", trim: true)

    rules = parse_rules(raw_rules)

    [my_ticket] = parse_tickets(raw_my)

    parse_tickets(raw_nearby)
    |> Enum.filter(&(scanning_error(&1, rules) == 0))
    |> find_index_mapping(rules)
    |> Map.to_list()
    |> Enum.filter(fn {_id, name} -> String.contains?(name, "departure") end)
    |> Enum.reduce(1, fn {id, _name}, acc -> acc * Enum.at(my_ticket, id) end)
  end

  def find_index_mapping(tickets, rules) do
    possibilities =
      for idx <- 0..(map_size(rules) - 1),
          rule <- rules,
          is_indexed_rule_valid?(tickets, idx, rule),
          do: {idx, rule}

    {result, _} =
      Enum.chunk_by(possibilities, fn {idx, _rule} -> idx end)
      |> Enum.sort(fn v1, v2 -> length(v1) < length(v2) end)
      |> Enum.reduce({%{}, MapSet.new()}, fn [{idx, _} | _] = candidates, {acc, choosen} ->
        valid =
          Enum.map(candidates, fn {_idx, {name, _ranges}} -> name end)
          |> MapSet.new()
          |> MapSet.difference(choosen)
          |> MapSet.to_list()
          |> List.first()

        {Map.put(acc, idx, valid), MapSet.put(choosen, valid)}
      end)

    result
  end

  def is_indexed_rule_valid?(tickets, idx, {_name, ranges}),
    do: Enum.all?(tickets, &valid_rule?(Enum.at(&1, idx), ranges))

  def valid_rule?(value, [r1, r2]),
    do: value in r1 || value in r2

  def scanning_error(ticket, rules) do
    Enum.reduce(ticket, 0, fn field, acc ->
      if !Enum.any?(rules, fn {_name, rule} -> valid_rule?(field, rule) end) do
        acc + field
      else
        acc
      end
    end)
  end

  def parse_rules(raw) do
    String.split(raw, "\n")
    |> Enum.reduce(%{}, fn v, acc ->
      [_, name | ranges] = Regex.run(@rules_regex, v)

      # rs means range start, re means range end
      [rs1, re1, rs2, re2] = Enum.map(ranges, &String.to_integer/1)

      Map.put(acc, name, [rs1..re1, rs2..re2])
    end)
  end

  def parse_tickets(raw) do
    String.split(raw, "\n")
    |> tl()
    |> Enum.map(fn t ->
      String.split(t, ",")
      |> Enum.filter(fn v -> v != "" end)
      |> Enum.map(&String.to_integer/1)
    end)
  end
end

defmodule AOC.D17 do
  import AOC.Helper.Input

  defmodule Coord do
    defstruct x: 0, y: 0, z: 0, w: 0
  end

  def run1(test \\ false) do
    get_input("D17", test)
    |> split_input()
    |> init()
    |> cycles(6)
    |> Enum.count()
  end

  def run2(test \\ false) do
    get_input("D17", test)
    |> split_input()
    |> init()
    |> cycles(6)
    |> Enum.count()
  end

  def cycles(state, 0), do: state

  def cycles(state, turns) do
    new_state =
      Enum.reduce(gen_extended_coords(state), %{}, fn coord, nstate ->
        # neighbors count
        neighbors = count_neighbors(coord, state)

        cond do
          # if satellite
          # check if neighbors count match the rules
          Map.get(state, coord) && 2 <= neighbors && neighbors <= 3 ->
            Map.put(nstate, coord, :satellite)

          # if no satellite check if neighbors count is exactly 3
          neighbors == 3 ->
            Map.put(nstate, coord, :satellite)

          # cell is empty
          true ->
            nstate
        end
      end)

    cycles(new_state, turns - 1)
  end

  def count_neighbors(coord, state) do
    found =
      for x <- (coord.x - 1)..(coord.x + 1),
          y <- (coord.y - 1)..(coord.y + 1),
          z <- (coord.z - 1)..(coord.z + 1),
          {x, y, z} != {coord.x, coord.y, coord.z},
          Map.get(state, %Coord{x: x, y: y, z: z}),
          do: :found

    Enum.count(found)
  end

  def gen_extended_coords(state) do
    for x <- extend_dimension(state, :x),
        y <- extend_dimension(state, :y),
        z <- extend_dimension(state, :z),
        do: %Coord{x: x, y: y, z: z}
  end

  def extend_dimension(state, dim) do
    Enum.map(state, fn {coord, _value} -> Map.get(coord, dim) end)
    |> Enum.min_max()
    |> to_extended_range()
  end

  def to_extended_range({a, b}), do: (a - 1)..(b + 1)

  def init(lines) do
    Enum.with_index(lines)
    |> Enum.reduce(%{}, fn {line, y}, acc ->
      String.graphemes(line)
      |> Enum.with_index()
      |> Enum.filter(fn {cube, _x} -> cube == "#" end)
      |> Enum.reduce(acc, fn {_cube, x}, acc ->
        Map.put(acc, %Coord{x: x, y: y}, :satellite)
      end)
    end)
  end
end
