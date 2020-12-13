defmodule AOC.D7 do
  import AOC.Helper.Input

  @bags_contains ~r/\sbags contain\s/
  @contains_bags ~r/\s?(\d+)\s([a-z ]*) bag(?:s?).?/

  @target "shiny gold"

  def run1(test \\ false) do
    bags =
      get_input("D7", test)
      |> split_input()
      |> Enum.reduce(%{}, fn v, acc ->
        {name, contains} = parse_line(v)
        Map.put(acc, name, contains)
      end)

    Enum.filter(bags, fn {name, _contains} ->
      name != @target && contains?(Map.get(bags, name), @target, bags)
    end)
    |> Enum.count()
  end

  def run2(test \\ false) do
    bags =
      get_input("D7", test)
      |> split_input()
      |> Enum.reduce(%{}, fn v, acc ->
        {name, contains} = parse_line(v)
        Map.put(acc, name, contains)
      end)

    Enum.reduce(Map.get(bags, @target), 0, fn {name, quantity}, acc ->
      acc + count(Map.get(bags, name), quantity, bags)
    end)
  end

  def parse_line(line) do
    [name, contain_bags] = String.split(line, @bags_contains)

    contains =
      case contain_bags do
        "no other bags." ->
          %{}

        contain ->
          String.split(contain, ",")
          |> Enum.reduce(%{}, fn v, acc ->
            [_, quantity, type] = Regex.run(@contains_bags, v)
            Map.put(acc, type, String.to_integer(quantity))
          end)
      end

    {name, contains}
  end

  def count(contains, acc, bags) when contains != %{} do
    Enum.map(contains, fn {name, quantity} ->
      acc * count(Map.get(bags, name), quantity, bags)
    end)
    |> Enum.sum()
    |> add(acc)
  end

  def count(_contains, acc, _bags), do: acc

  def add(a, b), do: a + b

  def contains?(contains, target, bags) when contains != %{} do
    if Map.has_key?(contains, target) do
      true
    else
      Enum.find_value(contains, false, fn {name, _quantity} ->
        contains?(Map.get(bags, name), target, bags)
      end)
    end
  end

  def contains?(_contains, _target, _bags), do: false
end

defmodule AOC.D8 do
  import AOC.Helper.Input

  defmodule Instruction do
    defstruct code: :nop, sign: 1, value: 0
  end

  def run1() do
    {:error, acc} =
      get_input("D8")
      |> split_input()
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn inst, acc ->
        reducer(inst, acc)
      end)
      |> run(0, 0, MapSet.new())

    acc
  end

  def run2() do
    {:ok, acc} =
      get_input("D8")
      |> split_input()
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn inst, acc ->
        reducer(inst, acc)
      end)
      |> fix()

    acc
  end

  def run(prg, acc, ip, visited) do
    cond do
      MapSet.member?(visited, ip) ->
        {:error, acc}

      ip >= map_size(prg) ->
        {:ok, acc}

      true ->
        inst = Map.get(prg, ip)

        {nacc, nip} =
          case inst.code do
            :jmp -> {acc, ip + inst.sign * inst.value}
            :nop -> {acc, ip + 1}
            :acc -> {acc + inst.sign * inst.value, ip + 1}
            code -> raise "Invalid instruction #{code}"
          end

        run(prg, nacc, nip, MapSet.put(visited, ip))
    end
  end

  def fix(prg) do
    Enum.find_value(0..(map_size(prg) - 1), fn i ->
      inst = Map.get(prg, i)

      updated =
        case inst.code do
          :jmp -> %{inst | code: :nop}
          :nop -> %{inst | code: :jmp}
          _ -> nil
        end

      if updated do
        case run(Map.replace(prg, i, updated), 0, 0, MapSet.new()) do
          {:ok, acc} ->
            {:ok, acc}

          {:error, _acc} ->
            false
        end
      end
    end)
  end

  def reducer({inst, idx}, acc) do
    <<code::bytes-size(3), " ", sign::bytes-size(1)>> <> num = inst
    sign = if sign == "+", do: 1, else: -1

    Map.put(acc, idx, %Instruction{
      code: String.to_atom(code),
      sign: sign,
      value: String.to_integer(num)
    })
  end
end

defmodule AOC.D9 do
  import AOC.Helper.Input

  @preamble_len 25

  def run1() do
    get_input("D9")
    |> split_input()
    |> Enum.map(&String.to_integer/1)
    |> find_first_mismatch()
  end

  def run2() do
    values =
      get_input("D9")
      |> split_input()
      |> Enum.map(&String.to_integer/1)

    find_first_mismatch(values)
    |> find_range(values)
  end

  def find_range(target, [rh | rt]) do
    case search_in_range(target, [rh], rt) do
      :next -> find_range(target, rt)
      {min, max} -> min + max
    end
  end

  def search_in_range(target, range, [h | t]) do
    case Enum.sum([h | range]) do
      x when x < target -> search_in_range(target, [h | range], t)
      x when x > target -> :next
      _ -> Enum.min_max([h | range])
    end
  end

  def find_first_mismatch(values) do
    find_first_mismatch(Enum.take(values, @preamble_len), Enum.drop(values, @preamble_len))
  end

  def find_first_mismatch(pool, [current | rest]) do
    pairs = for x <- pool, y <- pool, x != y, x + y == current, do: {x, y}

    case pairs do
      [] -> current
      _ -> find_first_mismatch(Enum.drop(pool, 1) ++ [current], rest)
    end
  end
end

defmodule AOC.D10 do
  import AOC.Helper.Input

  def run1(test \\ false) do
    {_, %{1 => ones, 3 => threes}} =
      get_input("D10", test)
      |> split_input()
      |> Enum.map(&String.to_integer/1)
      |> Enum.sort()
      |> find_jolts_deltas()

    ones * threes
  end

  def run2(test \\ false) do
    get_input("D10", test)
    |> split_input()
    |> Enum.map(&String.to_integer/1)
    |> Enum.sort()
    |> reduce_combinations()
    |> Enum.map(&tribo/1)
    |> Enum.reduce(&Kernel.*/2)
  end

  def reduce_combinations(list) do
    {reduced, _} =
      Enum.reduce(list, {[1], 0}, fn v, {[h | t] = l, previous} ->
        if v - previous == 1 do
          {[h + 1 | t], v}
        else
          {[1 | l], v}
        end
      end)

    reduced
  end

  def tribo(0), do: 0
  def tribo(1), do: 1
  def tribo(2), do: 1
  def tribo(n), do: tribo(n - 1) + tribo(n - 2) + tribo(n - 3)

  def find_jolts_deltas(inputs) do
    counters = %{0 => 0, 1 => 1, 2 => 1, 3 => 1}

    Enum.reduce(inputs, {List.first(inputs), counters}, fn v, {previous, counters} ->
      {v, Map.put(counters, v - previous, Map.get(counters, v - previous) + 1)}
    end)
  end
end

defmodule AOC.D11 do
  import AOC.Helper.Input

  @free "L"
  @occupied "#"
  @floor "."

  @dirs [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}]

  def run1(test \\ false) do
    get_input("D11", test)
    |> split_input()
    |> Enum.map(&String.graphemes/1)
    |> map_to_map()
    |> stabilize(:mistake)
    |> Enum.filter(fn {_coords, v} -> v == @occupied end)
    |> Enum.count()
  end

  def run2(test \\ false) do
    get_input("D11", test)
    |> split_input()
    |> Enum.map(&String.graphemes/1)
    |> map_to_map()
    |> stabilize(:no_mistake)
    |> Enum.filter(fn {_coords, v} -> v == @occupied end)
    |> Enum.count()
  end

  def map_to_map(map) do
    Enum.with_index(map)
    |> Enum.reduce(%{}, fn {l, y}, acc ->
      Enum.with_index(l)
      |> Enum.reduce(%{}, fn {v, x}, acc ->
        Map.put(acc, {y, x}, v)
      end)
      |> Map.merge(acc)
    end)
  end

  def stabilize(map, kind), do: stabilize(map, step(map, kind), kind)

  def stabilize(previous, current, _kind) when previous == current, do: current

  def stabilize(_previous, current, kind),
    do: stabilize(current, step(current, kind), kind)

  def step(current, kind) do
    Enum.reduce(current, %{}, fn {{x, y}, v}, acc ->
      case kind do
        :mistake ->
          cond do
            v == @free && adj(current, {x, y}) == 0 -> Map.put(acc, {x, y}, @occupied)
            v == @occupied && adj(current, {x, y}) >= 4 -> Map.put(acc, {x, y}, @free)
            true -> Map.put(acc, {x, y}, v)
          end

        :no_mistake ->
          cond do
            v == @free && neighbours(current, {x, y}) == 0 -> Map.put(acc, {x, y}, @occupied)
            v == @occupied && neighbours(current, {x, y}) >= 5 -> Map.put(acc, {x, y}, @free)
            true -> Map.put(acc, {x, y}, v)
          end

        _ ->
          raise "Kind #{kind} not supported"
      end
    end)
  end

  def adj(current, {x, y}) do
    Enum.reduce(@dirs, 0, fn {dx, dy}, acc ->
      xx = x + dx
      yy = y + dy

      if occupied?(current, {xx, yy}), do: acc + 1, else: acc
    end)
  end

  # this is slow...
  def neighbours(current, {x, y}) do
    Enum.reduce(@dirs, 0, fn {dx, dy}, acc ->
      [v] =
        Stream.iterate(1, &(&1 + 1))
        |> Stream.map(fn mul -> {x + dx * mul, y + dy * mul} end)
        |> Stream.map(fn {xx, yy} -> Map.get(current, {xx, yy}) end)
        |> Stream.drop_while(&(&1 == @floor))
        |> Enum.take(1)

      if v == @occupied, do: acc + 1, else: acc
    end)
  end

  def occupied?(current, coords) do
    Map.get(current, coords) == @occupied
  end
end

defmodule AOC.D12 do
  import AOC.Helper.Input

  def run1(test \\ false) do
    get_input("D12", test)
    |> split_input()
    |> Enum.map(&parse_directive/1)
    |> Enum.reduce({{0, 0}, {1, 0}}, &ship_instruction/2)
    |> (fn {{x, y}, _} -> abs(x) + abs(y) end).()
  end

  def run2(test \\ false) do
    get_input("D12", test)
    |> split_input()
    |> Enum.map(&parse_directive/1)
    |> Enum.reduce({{0, 0}, {10, 1}}, &wp_instruction/2)
    |> (fn {{x, y}, _} -> abs(x) + abs(y) end).()
  end

  def parse_directive(directive) do
    <<inst::bytes-size(1)>> <> value = directive
    {String.to_atom(inst), String.to_integer(value)}
  end

  def move(v, {{x, y}, {dx, dy}}), do: {{x + dx * v, y + dy * v}, {dx, dy}}

  def ship_instruction({:F, v}, state), do: move(v, state)

  def ship_instruction({:N, v}, {{x, y}, dir}), do: {{x, y + v}, dir}
  def ship_instruction({:S, v}, {{x, y}, dir}), do: {{x, y - v}, dir}
  def ship_instruction({:E, v}, {{x, y}, dir}), do: {{x + v, y}, dir}
  def ship_instruction({:W, v}, {{x, y}, dir}), do: {{x - v, y}, dir}

  def ship_instruction({:R, v}, {pos, dir}), do: {pos, rr(dir, v)}
  def ship_instruction({:L, v}, {pos, dir}), do: {pos, rl(dir, v)}

  def wp_instruction({:F, v}, state), do: move(v, state)

  def wp_instruction({:N, v}, {pos, {dx, dy}}), do: {pos, {dx, dy + v}}
  def wp_instruction({:S, v}, {pos, {dx, dy}}), do: {pos, {dx, dy - v}}
  def wp_instruction({:E, v}, {pos, {dx, dy}}), do: {pos, {dx + v, dy}}
  def wp_instruction({:W, v}, {pos, {dx, dy}}), do: {pos, {dx - v, dy}}

  def wp_instruction({:R, v}, {pos, dir}), do: {pos, rr(dir, v)}
  def wp_instruction({:L, v}, {pos, dir}), do: {pos, rl(dir, v)}

  def rr(dir, 0), do: dir
  def rr({dx, dy}, deg), do: rr({dy, -dx}, deg - 90)

  def rl(dir, 0), do: dir
  def rl({dx, dy}, deg), do: rl({-dy, dx}, deg - 90)
end

defmodule AOC.D13 do
  import AOC.Helper.Input

  def run1(test \\ false) do
    [st, buses] =
      get_input("D13", test)
      |> split_input()

    start = String.to_integer(st)

    ids =
      String.split(buses, ",")
      |> Enum.filter(&(&1 != "x"))
      |> Enum.map(&String.to_integer/1)

    {wait, line} =
      Enum.reduce(ids, {start, start}, fn lno, {soonest, l} ->
        case lno - rem(start, lno) do
          w when w < soonest ->
            {w, lno}

          _ ->
            {soonest, l}
        end
      end)

    wait * line
  end

  def run2(test \\ false) do
    [_, buses] =
      get_input("D13", test)
      |> split_input()

    {schedule, _} =
      String.split(buses, ",")
      |> Enum.reduce({%{}, 0}, fn v, {schedule, count} ->
        if v == "x" do
          {schedule, count + 1}
        else
          {Map.put(schedule, String.to_integer(v), count), count + 1}
        end
      end)

    {res, _} =
      Enum.reduce(schedule, {1, 1}, fn {l, t}, {min, product} ->
        [res] =
          Stream.iterate(min, &(&1 + product))
          |> Stream.drop_while(&(rem(&1 + t, l) != 0))
          |> Enum.take(1)

        {res, product * l}
      end)

    res
  end
end
