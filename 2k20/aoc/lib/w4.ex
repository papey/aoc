defmodule AOC.D21 do
  import AOC.Helper.Input

  def run1(test \\ false) do
    foods =
      get_input("D21", test)
      |> split_input()
      |> Enum.map(&parse/1)

    {safe, _alls_to_ings} = identify_ingredients(foods)

    Enum.reduce(foods, 0, fn {ings, _alls}, acc ->
      count =
        Enum.filter(ings, fn ing ->
          Enum.member?(safe, ing)
        end)
        |> Enum.count()

      acc + count
    end)
  end

  def run2(test \\ false) do
    foods =
      get_input("D21", test)
      |> split_input()
      |> Enum.map(&parse/1)

    {_safe, alls_to_ings} = identify_ingredients(foods)

    # sort
    sort_by_map_size(alls_to_ings)
    # identify allergens to ingredients
    |> identify_allergens()
    |> Enum.sort(fn {a1, _i1}, {a2, _i2} ->
      a1 < a2
    end)
    |> Enum.map(fn {_, i} -> i end)
    |> Enum.join(",")
  end

  def identify_allergens(list), do: identify_allergens(%{}, list)

  # no allergens left, just return the map of results
  def identify_allergens(results, []), do: results

  def identify_allergens(results, [{allergen_name, ingredients_set} | rest]) do
    # head of the list contains the current considered allergen
    # the set associated to this allergen contains only one ingredient
    # so just extract it
    ingredient_name = MapSet.to_list(ingredients_set) |> hd

    # update the rest list by removing the previous found ingredient name
    # resort everything after
    updated_rest =
      Enum.map(rest, fn {all, ings} ->
        {all, MapSet.delete(ings, ingredient_name)}
      end)
      |> sort_by_map_size()

    # loop until there is no more allergens
    identify_allergens(Map.put(results, allergen_name, ingredient_name), updated_rest)
  end

  def sort_by_map_size(list) do
    Enum.sort(list, fn {_k1, v1}, {_k2, v2} ->
      MapSet.size(v1) < MapSet.size(v2)
    end)
  end

  def identify_ingredients(foods) do
    # for each food, map allergens to ingredients
    {ings, alls_to_ings} =
      Enum.reduce(foods, {MapSet.new(), %{}}, fn
        {entry_ings, entry_alls}, {ingredients, alls_to_ings} ->
          alls_to_ings =
            Enum.reduce(entry_alls, alls_to_ings, fn all, acc ->
              {_, updated} =
                Map.get_and_update(acc, all, fn old ->
                  if old do
                    {old, MapSet.intersection(old, entry_ings)}
                  else
                    {old, MapSet.new(entry_ings)}
                  end
                end)

              updated
            end)

          {MapSet.union(ingredients, entry_ings), alls_to_ings}
      end)

    # set of each ingredient considered allergens
    allergens =
      Enum.reduce(alls_to_ings, MapSet.new(), fn {_all, ings}, acc ->
        MapSet.union(acc, ings)
      end)

    safe = MapSet.difference(ings, allergens) |> MapSet.to_list()

    {safe, alls_to_ings}
  end

  def parse(line) do
    [raw_ingredients, raw_allergens] = String.split(line, "(contains ")

    ingredients =
      String.split(raw_ingredients)
      |> Enum.map(&String.trim/1)
      |> MapSet.new()

    allergens =
      String.trim(raw_allergens, ")")
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> MapSet.new()

    {ingredients, allergens}
  end
end

defmodule AOC.D22 do
  import AOC.Helper.Input

  def run1(test \\ false) do
    [p1, p2] =
      get_input("D22", test)
      |> String.split("\n\n")

    d1 = parse_deck(p1)
    d2 = parse_deck(p2)

    round(0, d1, d2)
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {v, i}, acc -> acc + v * i end)
  end

  def run2(test \\ false) do
    [p1, p2] =
      get_input("D22", test)
      |> String.split("\n\n")

    d1 = parse_deck(p1)
    d2 = parse_deck(p2)

    play(d1, d2, MapSet.new())
    |> (fn {_, deck} -> deck end).()
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {v, i}, acc -> acc + v * i end)
  end

  def play([], d2, _seen), do: {:p2, d2}

  def play(d1, [], _seen), do: {:p1, d1}

  def play([c1 | r1] = d1, [c2 | r2] = d2, seen) do
    cond do
      MapSet.member?(seen, {d1, d2}) ->
        {:p1, d1}

      c1 <= length(r1) && c2 <= length(r2) ->
        nd1 = Enum.take(r1, c1)
        nd2 = Enum.take(r2, c2)

        case play(nd1, nd2, MapSet.new()) do
          {:p1, _} ->
            play(r1 ++ [c1, c2], r2, MapSet.put(seen, {d1, d2}))

          {:p2, _} ->
            play(r1, r2 ++ [c2, c1], MapSet.put(seen, {d1, d2}))
        end

      c1 > c2 ->
        play(r1 ++ [c1, c2], r2, MapSet.put(seen, {d1, d2}))

      true ->
        play(r1, r2 ++ [c2, c1], MapSet.put(seen, {d1, d2}))
    end
  end

  def round(_n, d1, []), do: d1

  def round(_n, [], d2), do: d2

  def round(n, [c1 | d1], [c2 | d2]) do
    if c1 > c2 do
      round(n + 1, d1 ++ [c1, c2], d2)
    else
      round(n + 1, d1, d2 ++ [c2, c1])
    end
  end

  def parse_deck(list) do
    String.split(list, "\n")
    |> tl()
    |> Enum.map(&String.to_integer/1)
  end
end

defmodule AOC.D23 do
  import AOC.Helper.Input

  @size 1_000_000

  def run1(test \\ false) do
    turns = 100
    len = 8

    get_input("D23", test)
    |> String.split("")
    |> Enum.filter(fn v -> v != "" end)
    |> Enum.map(&String.to_integer/1)
    |> Stream.iterate(&rounds/1)
    |> Enum.at(turns)
    |> Stream.cycle()
    |> Stream.drop_while(&(&1 != 1))
    |> Enum.slice(1, len)
    |> Enum.join("")
  end

  def run2(test \\ false) do
    turns = 10_000_000

    list =
      get_input("D23", test)
      |> String.split("")
      |> Enum.filter(fn v -> v != "" end)
      |> Enum.map(&String.to_integer/1)

    cups = init(list, length(list)..@size)

    {_, final, _} =
      Stream.iterate({List.first(list), cups, 0}, &moves/1)
      |> Enum.at(turns)

    Map.get(final, 1) * Map.get(final, Map.get(final, 1))
  end

  def init(init, rstart..rend) do
    cups = init ++ Enum.to_list((rstart + 1)..rend)

    values =
      Enum.slice(init, 1, length(init)) ++ Enum.to_list((rstart + 1)..rend) ++ [Enum.at(init, 0)]

    Enum.zip(cups, values)
    |> Enum.into(%{})
  end

  def moves({current, cups, turns}, size \\ @size) do
    {_, data} =
      Enum.reduce(0..3, {current, []}, fn _, {current, data} ->
        next = Map.get(cups, current)
        {next, data ++ [next]}
      end)

    {pickups, [next]} = Enum.split(data, 3)

    max =
      Enum.reduce(Enum.sort([current | pickups]), size, fn candidate, max ->
        if candidate == max, do: max - 1, else: max
      end)

    dst = destination(current - 1, pickups, 1, max)

    {next,
     Map.put(cups, current, next)
     |> Map.put(dst, hd(pickups))
     |> Map.put(List.last(pickups), Map.get(cups, dst)), turns + 1}
  end

  def rounds([current, p1, p2, p3 | rest] = list) do
    dst = destination(current - 1, [p1, p2, p3], Enum.min(list), Enum.max(rest))

    next =
      Stream.cycle([current | rest])
      |> Stream.drop_while(&(&1 != dst))
      |> Enum.slice(1, length(list) - 3)

    Stream.cycle([p1, p2, p3 | next])
    |> Stream.drop_while(&(&1 != current))
    |> Enum.slice(1, length(list))
  end

  def destination(current, _pickups, min, max) when current < min, do: max

  def destination(current, pickups, min, max) do
    if current in pickups do
      destination(current - 1, pickups, min, max)
    else
      current
    end
  end
end

defmodule AOC.D24 do
  import AOC.Helper.Input

  @dir %{
    "e" => {1, 0},
    "w" => {-1, 0},
    "se" => {0, 1},
    "sw" => {-1, 1},
    "nw" => {0, -1},
    "ne" => {1, -1}
  }

  def run1(test \\ false) do
    get_input("D24", test)
    |> split_input()
    |> Enum.reduce(%{}, fn instruction, tiles ->
      dir = build_path(instruction)

      case Map.get(tiles, dir) do
        nil ->
          Map.put(tiles, dir, true)

        state ->
          Map.put(tiles, dir, !state)
      end
    end)
    |> Enum.count(fn {_key, v} -> v == true end)
  end

  def run2(test \\ false) do
    get_input("D24", test)
    |> split_input()
    |> Enum.reduce(%{}, fn instruction, tiles ->
      dir = build_path(instruction)

      discovered = discover(tiles, dir)

      case Map.get(discovered, dir) do
        nil ->
          Map.put(discovered, dir, true)

        state ->
          Map.put(discovered, dir, !state)
      end
    end)
    |> days(100)
    |> Enum.count(fn {_key, v} -> v == true end)
  end

  def days(map, 0), do: map

  def days(map, target) do
    next =
      Enum.reduce(map, map, fn {pos, is_black}, next ->
        neighbours = nb(map, pos)

        discovered = discover(next, pos)

        cond do
          is_black && (neighbours == 0 || neighbours > 2) ->
            Map.put(discovered, pos, false)

          !is_black && neighbours == 2 ->
            Map.put(discovered, pos, true)

          true ->
            discovered
        end
      end)

    days(next, target - 1)
  end

  def discover(map, {q, r}) do
    discovery = for {_key, dir} <- @dir, do: dir

    Enum.reduce(discovery, map, fn {dq, dr}, next ->
      if Map.get(next, {q + dq, r + dr}) do
        next
      else
        Map.put(next, {q + dq, r + dr}, false)
      end
    end)
  end

  def nb(map, {q, r}) do
    neighbours = for {_key, {dq, dr}} <- @dir, do: Map.get(map, {dq + q, dr + r})

    Enum.count(neighbours, fn v -> v == true end)
  end

  def build_path(instruction), do: build_path(instruction, {0, 0})

  def build_path("", dir), do: dir

  def build_path("e" <> rest, {dq, dr}) do
    {qq, rr} = Map.get(@dir, "e")
    build_path(rest, {dq + qq, dr + rr})
  end

  def build_path("w" <> rest, {dq, dr}) do
    {qq, rr} = Map.get(@dir, "w")
    build_path(rest, {dq + qq, dr + rr})
  end

  def build_path("se" <> rest, {dq, dr}) do
    {qq, rr} = Map.get(@dir, "se")
    build_path(rest, {dq + qq, dr + rr})
  end

  def build_path("sw" <> rest, {dq, dr}) do
    {qq, rr} = Map.get(@dir, "sw")
    build_path(rest, {dq + qq, dr + rr})
  end

  def build_path("nw" <> rest, {dq, dr}) do
    {qq, rr} = Map.get(@dir, "nw")
    build_path(rest, {dq + qq, dr + rr})
  end

  def build_path("ne" <> rest, {dq, dr}) do
    {qq, rr} = Map.get(@dir, "ne")
    build_path(rest, {dq + qq, dr + rr})
  end
end
