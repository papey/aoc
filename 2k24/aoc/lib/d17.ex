defmodule D17 do
  import Bitwise

  def p1 do
    [raw_registers, raw_instructions] = Parser.parse("inputs/d17.txt", "\n\n")

    instructions =
      raw_instructions
      |> String.replace("Program: ", "")
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    registers =
      raw_registers
      |> String.split("\n")
      |> Enum.reduce(%{}, fn line, acc ->
        [_, name, value] = Regex.scan(~r/Register (\w): (\d+)/, line) |> hd()

        Map.put(acc, name, String.to_integer(value))
      end)

    run(instructions, registers)
    |> elem(1)
    |> Enum.join(",")
  end

  def p2 do
    [_raw_registers, raw_instructions] = Parser.parse("inputs/d17.txt", "\n\n")

    instructions =
      raw_instructions
      |> String.replace("Program: ", "")
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    find(instructions) |> Enum.min()
  end

  def find(program) do
    Enum.reduce(0..8, [], fn a, acc ->
      find(a, program, acc, 0)
    end)
  end

  defp step(a) do
    b = rem(a, 8)
    b = Bitwise.bxor(b, 2)
    c = div(a, :math.pow(2, b) |> round)
    b = Bitwise.bxor(b, 3)
    b = Bitwise.bxor(b, c)
    rem(b, 8)
  end

  defp find(a, program, results, index) do
    if step(a) == Enum.at(program, length(program) - (index + 1)) do
      if index == length(program) - 1 do
        [a | results]
      else
        Enum.reduce(0..7, results, fn b, acc ->
          find(a * 8 + b, program, acc, index + 1)
        end)
      end
    else
      results
    end
  end

  defp run(instructions, registers) do
    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while({0, instructions, registers, []}, fn _,
                                                              {ip, instructions, registers, out} ->
      if ip + 1 <= length(instructions) do
        [opcode, literal_operand] = Enum.slice(instructions, ip, 2)

        [next_registers, out, nip] =
          case opcode do
            0 ->
              div(registers, "A", literal_operand, out, ip)

            1 ->
              bxor(registers, "B", registers["B"], literal_operand, out, ip)

            2 ->
              bst(registers, literal_operand, out, ip)

            3 ->
              jnz(registers, literal_operand, out, ip)

            4 ->
              bxor(registers, "B", registers["B"], registers["C"], out, ip)

            5 ->
              out(registers, literal_operand, out, ip)

            6 ->
              div(registers, "B", literal_operand, out, ip)

            7 ->
              div(registers, "C", literal_operand, out, ip)
          end

        {:cont, {nip, instructions, next_registers, out}}
      else
        {:halt, {registers, out}}
      end
    end)
  end

  defp bxor(registers, register, a, b, out, ip) do
    [Map.put(registers, register, bxor(a, b)), out, ip + 2]
  end

  defp bst(registers, literal, out, ip) do
    combo_operand = combo(registers, literal)
    [Map.put(registers, "B", rem(combo_operand, 8)), out, ip + 2]
  end

  defp out(registers, literal, out, ip) do
    combo_operand = combo(registers, literal)
    [registers, out ++ [rem(combo_operand, 8)], ip + 2]
  end

  defp jnz(registers, literal, out, ip) do
    case registers["A"] do
      0 ->
        [registers, out, ip + 2]

      _ ->
        [registers, out, literal]
    end
  end

  defp div(registers, register, literal, out, ip) do
    [
      Map.put(
        registers,
        register,
        div(registers["A"], :math.pow(2, combo(registers, literal)) |> trunc)
      ),
      out,
      ip + 2
    ]
  end

  defp combo(registers, literal) do
    case literal do
      a when a in [0, 1, 2, 3] -> a
      4 -> registers["A"]
      5 -> registers["B"]
      6 -> registers["C"]
      _ -> nil
    end
  end
end
