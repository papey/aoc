import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string
import parser/parser

pub fn main() -> Nil {
  let assert Ok(input) = parser.parse("./inputs/d06.txt")

  // this is me playsing with the use keyword for fun and profit
  let p1 = {
    use raw_operands <- solve(input)
    let assert Ok(re) = regexp.from_string("\\s+")

    list.reverse(raw_operands)
    |> list.map(fn(line) {
      line
      |> string.trim()
      |> regexp.split(re, _)
      |> list.map(int.parse)
      |> list.map(result.unwrap(_, 0))
    })
    |> list.transpose
  }
  io.println("p1: " <> int.to_string(p1))

  let vertical_parse = fn(raw_operands: List(String)) -> List(List(Int)) {
    list.reverse(raw_operands)
    |> list.map(string.split(_, ""))
    |> list.transpose
    |> group([], [])
    |> list.map(fn(group) {
      list.map(group, fn(operand) {
        string.join(operand, "")
        |> string.trim
        |> int.parse
        |> result.unwrap(0)
      })
    })
  }

  let p2 = solve(input, vertical_parse)
  io.println("p1: " <> int.to_string(p2))
}

pub type Operation =
  fn(Int, Int) -> Int

fn solve(
  input: List(String),
  parse_operands: fn(List(String)) -> List(List(Int)),
) -> Int {
  let assert [raw_operations, ..raw_operands] = list.reverse(input)
  let operations = parse_operations(raw_operations)

  parse_operands(raw_operands)
  |> list.zip(operations)
  |> list.map(fn(entry) {
    let assert #([init, ..rest], op) = entry
    list.fold(rest, init, op)
  })
  |> int.sum
}

fn parse_operations(raw: String) -> List(Operation) {
  let assert Ok(re) = regexp.from_string("\\s+")

  string.trim(raw)
  |> regexp.split(re, _)
  |> list.map(fn(op) {
    case op {
      "+" -> fn(a, b) { a + b }
      "*" -> fn(a, b) { a * b }
      _ -> panic as "invalid state"
    }
  })
}

pub type Group =
  List(List(String))

fn group(to_group: Group, groups: List(Group), current: Group) -> List(Group) {
  case to_group {
    [] -> [current, ..groups] |> list.reverse
    [cur, ..rest] -> {
      let is_spacer =
        list.all(cur, fn(item) { string.trim(item) |> string.is_empty })
      case is_spacer {
        True -> group(rest, [current, ..groups], [])
        False -> group(rest, groups, [cur, ..current])
      }
    }
  }
}
