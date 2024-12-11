defmodule D11 do
  def p1 do
    state =
      Parser.parse("inputs/d11.txt")
      |> Enum.at(0)
      |> to_state()

    Enum.reduce(1..25, state, fn _, state -> blink(state) end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def p2 do
    state =
      Parser.parse("inputs/d11.txt")
      |> Enum.at(0)
      |> to_state()

    Enum.reduce(1..75, state, fn _, state -> blink(state) end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  defp blink(state) do
    Enum.reduce(state, %{}, fn {number, times}, acc ->
      cond do
        number == 0 ->
          [{1, times}]

        even_number_of_digits?(number) ->
          split(number)
          |> Enum.map(&{&1, times})

        true ->
          [{number * 2024, times}]
      end
      |> Enum.reduce(acc, fn {n, t}, acc ->
        Map.update(acc, n, t, &(&1 + t))
      end)
    end)
  end

  defp split(number) do
    digits = Integer.digits(number)
    middle = div(length(digits), 2)

    Enum.split(digits, middle)
    |> Tuple.to_list()
    |> Enum.map(&Enum.reduce(&1, 0, fn d, acc -> acc * 10 + d end))
  end

  defp even_number_of_digits?(number) do
    number
    |> Integer.digits()
    |> length()
    |> rem(2) == 0
  end

  defp to_state(line) do
    String.split(line, " ")
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&{&1, 1})
    |> Map.new()
  end
end
