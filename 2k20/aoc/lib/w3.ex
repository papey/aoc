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
    |> cycles(6, false)
    |> Enum.count()
  end

  def run2(test \\ false) do
    get_input("D17", test)
    |> split_input()
    |> init()
    |> cycles(6, true)
    |> Enum.count()
  end

  def cycles(state, 0, _extended), do: state

  def cycles(state, turns, extended) do
    new_state =
      Enum.reduce(gen_extended_coords(state, extended), %{}, fn coord, nstate ->
        # neighbors count
        neighbors = count_neighbors(coord, state, extended)

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

    cycles(new_state, turns - 1, extended)
  end

  def count_neighbors(coord, state, extended \\ false) do
    found =
      if extended do
        for x <- (coord.x - 1)..(coord.x + 1),
            y <- (coord.y - 1)..(coord.y + 1),
            z <- (coord.z - 1)..(coord.z + 1),
            w <- (coord.w - 1)..(coord.w + 1),
            {x, y, z, w} != {coord.x, coord.y, coord.z, coord.w},
            Map.get(state, %Coord{x: x, y: y, z: z, w: w}),
            do: :found
      else
        for x <- (coord.x - 1)..(coord.x + 1),
            y <- (coord.y - 1)..(coord.y + 1),
            z <- (coord.z - 1)..(coord.z + 1),
            {x, y, z} != {coord.x, coord.y, coord.z},
            Map.get(state, %Coord{x: x, y: y, z: z}),
            do: :found
      end

    Enum.count(found)
  end

  def gen_extended_coords(state, extended \\ false) do
    base =
      for x <- extend_dimension(state, :x),
          y <- extend_dimension(state, :y),
          z <- extend_dimension(state, :z),
          do: %Coord{x: x, y: y, z: z}

    if extended do
      for w <- extend_dimension(state, :w), c <- base, do: %Coord{x: c.x, y: c.y, z: c.z, w: w}
    else
      base
    end
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

defmodule AOC.D18 do
  import AOC.Helper.Input

  def run1() do
    solve([{"*", "-"}])
  end

  def run2() do
    solve([{"*", "-"}, {"+", "/"}])
  end

  def solve(changes) do
    get_input("D18")
    |> split_input()
    |> Enum.map(&replace(&1, changes))
    |> Enum.map(&Code.string_to_quoted!/1)
    |> Enum.map(&invert(&1, reverse_changes_map(changes)))
    |> Enum.map(&Code.eval_quoted/1)
    |> Enum.reduce(0, fn {res, _}, sum -> res + sum end)
  end

  def reverse_changes_map(changes) do
    Enum.reduce(changes, %{}, fn {f, t}, acc ->
      Map.put(acc, String.to_atom(t), String.to_atom(f))
    end)
  end

  def invert(op, _reverse) when is_number(op), do: op

  def invert({op, meta, [d1, d2]}, reverse) do
    {Map.get(reverse, op) || op, meta, [invert(d1, reverse), invert(d2, reverse)]}
  end

  def replace(input, changes) do
    Enum.reduce(changes, input, fn {f, t}, acc -> String.replace(acc, f, t) end)
  end
end

defmodule AOC.D19 do
  import AOC.Helper.Input

  def run1(test \\ false) do
    [raw_rules, raw_messages] =
      get_input("D19", test)
      |> String.split("\n\n", trim: true)
      |> Enum.map(&String.split(&1, "\n"))

    rules = rules_to_map(raw_rules)

    matcher =
      gen_matcher(rules, "0", false)
      |> (fn exp -> Enum.join(["^", exp, "$"], "") end).()
      |> Regex.compile!()

    Enum.filter(raw_messages, &Regex.match?(matcher, &1))
    |> Enum.count()
  end

  def run2(test \\ false) do
    [raw_rules, raw_messages] =
      get_input("D19", test)
      |> String.split("\n\n", trim: true)
      |> Enum.map(&String.split(&1, "\n"))

    rules = rules_to_map(raw_rules)

    matcher =
      gen_matcher(rules, "0", true)
      |> (fn exp -> Enum.join(["^", exp, "$"], "") end).()
      |> Regex.compile!()

    Enum.filter(raw_messages, &Regex.match?(matcher, &1))
    |> Enum.count()
  end

  def gen_matcher(rules, target \\ "0", extended \\ false)

  def gen_matcher(rules, "8", true) do
    Enum.join(["(", gen_matcher(rules, "42", true), ")+"], "")
  end

  def gen_matcher(rules, "11", true) do
    Enum.join(
      [
        "(?'recurse'(#{gen_matcher(rules, "42", true)})",
        "(?&recurse)?",
        "(#{gen_matcher(rules, "31", true)})",
        ")"
      ],
      ""
    )
  end

  def gen_matcher(_rules, letter, _extended) when letter == "a" or letter == "b" or letter == "|",
    do: letter

  def gen_matcher(rules, target, extended) do
    Map.get(rules, target)
    |> String.split(" ", trim: true)
    |> Enum.map(&gen_matcher(rules, &1, extended))
    |> case do
      [only] -> only
      list -> "(#{Enum.join(list, "")})"
    end
  end

  def rules_to_map(rules) do
    Enum.reduce(rules, %{}, fn rule, acc ->
      [ruleno, inst] =
        String.split(rule, ":")
        |> Enum.map(&String.trim/1)
        |> Enum.map(&String.replace(&1, "\"", ""))

      Map.put(acc, ruleno, inst)
    end)
  end
end

defmodule AOC.D20 do
  import AOC.Helper.Input
  use Bitwise

  # tile is a square of 10 by 10
  @len 10
  @edges_order [:u, :d, :l, :r]

  def run1(test \\ false) do
    get_input("D20", test)
    |> String.split("\n\n")
    |> parse_tiles()
    # Map all edges to corresponding tiles
    |> Enum.reduce(%{}, fn {id, tile}, acc ->
      edges = edges(tile)

      Enum.reduce(edges ++ Enum.map(edges, &flip/1), acc, fn edge, acc ->
        {_old, acc} =
          Map.get_and_update(acc, edge, fn old ->
            if old do
              {old, [id | old]}
            else
              {old, [id]}
            end
          end)

        acc
      end)
    end)
    # Filters out singleton
    |> Enum.filter(fn {_edge, ids} -> length(ids) == 1 end)
    # A list of one is just the element inside that list
    |> Enum.map(fn {edge, [id]} -> {edge, id} end)
    # Reverse the reduce to find how many edges maps this tile id
    |> Enum.reduce(%{}, fn {_edge, id}, acc ->
      {_old, acc} =
        Map.get_and_update(acc, id, fn old ->
          if old do
            {old, old + 1}
          else
            {old, 1}
          end
        end)

      acc
    end)
    # filter out candidates
    |> Enum.filter(fn {_id, match} -> match > 2 && match < 5 end)
    # reduce
    |> Enum.reduce(1, fn {id, _}, acc -> acc * id end)
  end

  @doc """
  Gets a unique value for each edge of a tile, up, down, left, right
  """
  def edges(tile), do: Enum.map(@edges_order, &edge(tile, &1))

  @doc """
  Get a value for specified edge
  """
  def edge(tile, :u),
    do: Enum.map(0..(@len - 1), &Map.get(tile, {&1, 0})) |> Enum.join("") |> String.to_integer(2)

  def edge(tile, :d),
    do:
      Enum.map(0..(@len - 1), &Map.get(tile, {&1, @len - 1}))
      |> Enum.join("")
      |> String.to_integer(2)

  def edge(tile, :l),
    do: Enum.map(0..(@len - 1), &Map.get(tile, {0, &1})) |> Enum.join("") |> String.to_integer(2)

  def edge(tile, :r),
    do:
      Enum.map(0..(@len - 1), &Map.get(tile, {@len - 1, &1}))
      |> Enum.join("")
      |> String.to_integer(2)

  @doc """
  Flip an edge
  """
  def flip(input),
    do:
      Enum.reduce(0..(@len - 1), 0, fn i, acc ->
        acc ||| (input >>> i &&& 1) <<< (@len - 1 - i)
      end)

  def parse_tiles(t) do
    Enum.reduce(t, %{}, fn t, acc ->
      [title | content] = String.split(t, "\n")
      [_, id] = Regex.run(~r/Tile (\d+):/, title)

      Map.put(acc, String.to_integer(id), parse_tile(content))
    end)
  end

  def parse_tile(content) do
    Enum.with_index(content)
    |> Enum.reduce(%{}, fn {raw, y}, acc ->
      String.graphemes(raw)
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {symbol, x}, acc ->
        if symbol == "#" do
          Map.put(acc, {x, y}, 1)
        else
          Map.put(acc, {x, y}, 0)
        end
      end)
    end)
  end
end
