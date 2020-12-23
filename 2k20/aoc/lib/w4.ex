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
