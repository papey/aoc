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

  @range -1..1
  @dirs for(x <- @range, y <- @range, do: {x, y})
        |> Enum.reject(fn d -> d == {0, 0} end)

  def run1(test \\ false) do
    get_input("D11", test)
    |> split_input()
    |> Enum.map(&String.graphemes/1)
    |> enrich_map()
    |> stabilize()
    |> Enum.reduce(0, fn {l, _}, acc ->
      acc + (Enum.filter(l, fn {v, _} -> v == @occupied end) |> Enum.count())
    end)
  end

  def enrich_map(map) do
    enriched =
      Enum.with_index(map)
      |> Enum.map(fn {l, y} ->
        {Enum.with_index(l), y}
      end)

    {enriched, {length(Enum.at(map, 0)), length(map)}}
  end

  def stabilize({map, size}), do: stabilize(map, step(map, size), size)

  def stabilize(previous, current, _size) when previous == current, do: current

  def stabilize(_previous, current, size) do
    stabilize(current, step(current, size), size)
  end

  def step(current, size) do
    Enum.map(current, fn {l, y} ->
      {Enum.map(l, fn {v, x} ->
         cond do
           v == @free && adj(current, x, y, size) == 0 -> {@occupied, x}
           v == @occupied && adj(current, x, y, size) >= 4 -> {@free, x}
           true -> {v, x}
         end
       end), y}
    end)
  end

  def adj(current, x, y, {xl, yl}) do
    Enum.reduce(@dirs, 0, fn {dx, dy}, acc ->
      xx = x + dx
      yy = y + dy

      if xx >= 0 && xx < xl && yy >= 0 && yy < yl && occupied?(current, xx, yy) do
        acc + 1
      else
        acc
      end
    end)
  end

  def occupied?(current, x, y) do
    {v, _} =
      Enum.at(current, y)
      |> (fn {raw, _y} -> Enum.at(raw, x) end).()

    v == @occupied
  end
end
