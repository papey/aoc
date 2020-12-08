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

  def run(prg, acc, ip, visited) do
    if MapSet.member?(visited, ip) do
      {:error, acc}
    else
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
