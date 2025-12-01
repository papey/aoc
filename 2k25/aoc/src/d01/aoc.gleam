import gleam/int
import gleam/io
import gleam/list
import gleam/string
import parser/parser

const size: Int = 100

const initial_position: Int = 50

pub fn main() -> Nil {
  let assert Ok(lines) = parser.parse("./inputs/d01.txt")

  let result =
    list.fold(lines, #(0, 0, initial_position), fn(accumulator, input) {
      let #(direction, delta) = parse_line(input)
      let dir = case direction {
        "L" -> -1
        "R" -> 1
        _ -> panic as "Invalid direction"
      }

      let #(count, crossings, position) = accumulator
      let #(new_crossings, new_position) = step(crossings, position, dir, delta)

      case new_position {
        0 -> #(count + 1, new_crossings, new_position)
        _ -> #(count, new_crossings, new_position)
      }
    })

  io.println("p1: " <> int.to_string(result.0))
  io.println("p2: " <> int.to_string(result.1))
}

pub fn step(
  crossings: Int,
  position: Int,
  direction: Int,
  delta: Int,
) -> #(Int, Int) {
  let assert Ok(next_position) = int.modulo(position + direction * delta, size)

  let crossed = case direction {
    1 -> {
      let assert Ok(crossed) = int.floor_divide(position + delta, size)
      crossed
    }
    _ -> {
      let assert Ok(forward) = int.modulo(size - position, size)
      let assert Ok(crossed) = int.floor_divide(forward + delta, size)
      crossed
    }
  }

  #(crossings + crossed, next_position)
}

fn parse_line(line: String) -> #(String, Int) {
  let assert Ok(direction) = string.to_graphemes(line) |> list.first
  let assert Ok(distance) = string.drop_start(line, 1) |> int.parse
  #(direction, distance)
}
