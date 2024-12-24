defmodule D24 do
  def p1 do
    [raw_wires, raw_conns] = Parser.parse("inputs/d24.txt", "\n\n")

    wires =
      raw_wires
      |> String.split("\n")
      |> Enum.reduce(%{}, fn raw_wire, acc ->
        [label, val] = String.split(raw_wire, ":") |> Enum.map(&String.trim/1)
        bval = if val == "1", do: true, else: false
        Map.put(acc, label, bval)
      end)

    conns =
      raw_conns
      |> String.split("\n")

    add(conns, wires)
  end

  def p2 do
    [_, raw_conns] = Parser.parse("inputs/d24.txt", "\n\n")

    conns =
      raw_conns
      |> String.split("\n")
      |> Enum.map(fn raw_conn ->
        [a, op, b, _, out] = String.split(raw_conn, " ")
        {a, op, b, out}
      end)

    # all single bit adders are chained together
    # https://media.geeksforgeeks.org/wp-content/uploads/digital_Logic2.png
    # all rules outputting to zXX should be mapped to a XOR gate (except the very last one)
    faulty_zout =
      Enum.filter(conns, fn {_, _, _, out} -> Regex.match?(~r/z\d+/, out) end)
      |> Enum.filter(&(elem(&1, 3) != "z45"))
      |> Enum.filter(&(elem(&1, 1) != "XOR"))

    # all rules outputting to something that is not zXX should be mapped to a AND or OR gate (no XOR)
    fault_non_zout =
      Enum.filter(conns, fn {a, op, b, out} ->
        !Regex.match?(~r/z\d+/, out) &&
          Enum.all?([a, b], fn v -> !Regex.match?(~r/[xy]\d+/, v) end) &&
          op not in ["AND", "OR"]
      end)

    # all rules with XOR inputting xXX and yXX (except first one) should be chained to a XOR gate
    faulty_xor =
      Enum.filter(conns, &(elem(&1, 1) == "XOR"))
      |> Enum.filter(fn {a, _, b, _} ->
        Enum.all?([a, b], fn v -> Regex.match?(~r/[xy]\d+/, v) end) &&
          Enum.any?([a, b], fn v -> v not in ["x00", "y00"] end)
      end)
      |> Enum.filter(fn {_, _, _, out} ->
        !Enum.any?(conns, fn {a, op, b, _} -> op == "XOR" && (a == out || b == out) end)
      end)

    # all rules with AND inputting xXX and yXX (except first one) should be chained to a OR gate
    faulty_and =
      Enum.filter(conns, &(elem(&1, 1) == "AND"))
      |> Enum.filter(fn {a, _, b, _} ->
        Enum.all?([a, b], fn v -> Regex.match?(~r/[xy]\d+/, v) end) &&
          Enum.any?([a, b], fn v -> v not in ["x00", "y00"] end)
      end)
      |> Enum.filter(fn {_, _, _, out} ->
        !Enum.any?(conns, fn {a, op, b, _} -> op == "OR" && (a == out || b == out) end)
      end)

    # feeling lucky
    (fault_non_zout ++ faulty_zout ++ faulty_and ++ faulty_xor)
    |> Enum.map(&elem(&1, 3))
    |> Enum.sort()
    |> Enum.uniq()
    |> Enum.join(",")
  end

  defp add(conns, wires) do
    resolve(conns, wires)
    |> Enum.to_list()
    |> Enum.filter(fn {l, _} -> String.starts_with?(l, "z") end)
    |> Enum.sort_by(fn {l, _} -> l end)
    |> Enum.reverse()
    |> Enum.map(&elem(&1, 1))
    |> Enum.map(fn v -> if v == true, do: 1, else: 0 end)
    |> Enum.join()
    |> String.to_integer(2)
  end

  defp resolve(conns, wires) do
    resolved_wires =
      Enum.reduce(conns, wires, fn conn, wires ->
        case String.split(conn, " ") do
          [a, "AND", b, _, out] -> Map.put(wires, out, wires[a] && wires[b])
          [a, "OR", b, _, out] -> Map.put(wires, out, wires[a] || wires[b])
          [a, "XOR", b, _, out] -> Map.put(wires, out, wires[a] != wires[b])
        end
      end)

    if wires == resolved_wires do
      resolved_wires
    else
      resolve(conns, resolved_wires)
    end
  end
end
