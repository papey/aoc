import gleam/int
import gleam/io
import gleam/list
import gleam/string
import parser/parser

pub fn main() -> Nil {
  let assert Ok(lines) = parser.parse("./inputs/d02.txt")
  let assert Ok(pid_ranges) = list.first(lines)

  io.println("p1: " <> int.to_string(part1(pid_ranges)))
  io.println("p2: " <> int.to_string(part2(pid_ranges)))
}

pub fn part1(pid_ranges: String) -> Int {
  let ranges = parse_ranges(pid_ranges)
  list.map(ranges, fn(range) {
    list.range(range.0, range.1)
    |> list.filter(fn(pid) {
      let spid = int.to_string(pid)
      let len = string.length(spid)
      int.is_even(len)
      && string.drop_end(spid, len / 2) == string.drop_start(spid, len / 2)
    })
    |> int.sum
  })
  |> int.sum
}

pub fn part2(pid_ranges: String) -> Int {
  let ranges = parse_ranges(pid_ranges)
  list.map(ranges, fn(range) {
    list.range(range.0, range.1)
    |> list.filter(fn(pid) {
      let spid = int.to_string(pid)
      case string.length(spid) {
        len if len > 1 -> {
          let chars = string.split(spid, "")
          list.any(list.range(1, len / 2), fn(i) {
            len % i == 0
            && list.sized_chunk(chars, i) |> list.unique |> list.length == 1
          })
        }
        _ -> False
      }
    })
    |> int.sum
  })
  |> int.sum
}

pub fn parse_ranges(pid_ranges: String) -> List(#(Int, Int)) {
  pid_ranges
  |> string.split(",")
  |> list.map(fn(range) {
    let assert Ok([start, end]) =
      string.split(range, "-") |> list.try_map(int.parse)
    #(start, end)
  })
}
