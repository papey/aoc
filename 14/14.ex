# oh oh oh oh
defmodule AOC do

  @trillion 1000000000000

  # main function for part 1
  def ores(input) do
    {ores, _cargo} = parse_input(input) |> produce({"FUEL", 1}, %{})
    IO.puts "Result, part 1 : " <> Integer.to_string(ores["ORE"])
  end

  # main function for part 2
  def maximum(input) do
    cookbook = parse_input(input)
    res = search(cookbook, 1, 0, @trillion, @trillion)
    IO.puts "Result, part 2 : " <> Integer.to_string(res)
  end


  # parse input, then enum on each line
  def parse_input(input) do
    File.stream!(input) |> Enum.map(fn line -> parse_line(line) end) |> Map.new
  end

  # split line between output and input
  def parse_line(line) do
    [output, inputs] = String.split(line, " => ") |> Enum.reverse()
    {name, q} = parse_elem(output)
    ingredients = String.split(inputs, ", ") |> Enum.map(fn elem -> parse_elem(elem) end)
    {name, {q, ingredients}}
  end

  # parse element
  def parse_elem(elem) do
    {q, n} = Integer.parse(elem)
    {String.trim(n), q}
  end

  # produce basic element
  def produce(_cookbook, {name = "ORE", quantity}, cargo) do
    {_amount, cargo} = from_cargo(name, quantity, cargo)
    # return ORE value and up to date cargo
    {%{"ORE" => quantity}, cargo}
  end

  # produce complex element
  def produce(cookbook, {name, quantity}, cargo) do
    # get from cargo
    {quantity, cargo} = from_cargo(name, quantity, cargo)
    # get target mix from cookbook
    {generated, ingredients} = Map.get(cookbook, name)
    # compute amount of stuff to produce
    to_produce = round(Float.ceil(quantity / generated))

    # compute needed elements
    {requirements, cargo} =
      # invoke for each ingredients and fill the accumulator
      Enum.reduce(ingredients, {%{}, cargo}, fn {name, amount}, {gen, cargo} ->
        # produce nedded quantity for given ingredient
        {requirements, cargo} = produce(cookbook, {name, amount * to_produce}, cargo)
        # merge requirements as ORE
        {Map.merge(requirements, gen, fn _k, r, g -> r + g end), cargo}
      end)

    {requirements, to_cargo(name, to_produce * generated - quantity, cargo)}
  end

  # get from cargo
  def from_cargo(name, quantity, cargo) do
    Map.get_and_update(cargo, name, fn
      nil -> {quantity, 0}
      from_cargo when quantity >= from_cargo -> {quantity - from_cargo, 0}
      from_cargo -> {0, from_cargo - quantity}
    end)
  end

  # put in cargo
  def to_cargo(name, quantity, cargo) do
    Map.update(cargo, name, quantity, &(&1 + quantity))
  end

  # binary search
  def search(cookbook, current, l, h, ore) do
  # get ore for current guess
  {res, _} = produce(cookbook, {"FUEL", current}, %{})
  computed = res["ORE"]
  cond do
    # found
    h - l <= 1 ->
      l
    # less
    computed < ore ->
      # change low value
      l = current
      # update current
      current = current + div((h-l), 2)
      # search with new limits
      search(cookbook, current, l, h, ore)
    # greater
    computed > ore ->
      # change high value
      h = current
      # update current
      current = current - div((h-l), 2)
      # search with new limits
      search(cookbook, current, l, h, ore)
    end
  end

end
