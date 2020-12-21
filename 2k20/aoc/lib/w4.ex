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
