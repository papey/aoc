import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/result
import gleam/string
import parser/parser

const p1_len: Int = 2

const p2_len: Int = 12

pub fn main() -> Nil {
  let assert Ok(lines) = parser.parse("./inputs/d03.txt")
  let inputs =
    list.map(lines, string.to_graphemes)
    |> list.map(fn(n) {
      list.map(n, fn(c) { int.parse(c) |> result.unwrap(0) })
    })

  let sorted = list.map(inputs, sort)

  let assert [p1, p2] =
    [p1_len, p2_len]
    |> list.map(fn(len) {
      sorted
      |> list.map(fn(line) { find_digits(line, len) })
      |> int.sum
      |> int.to_string
    })

  io.println("p1: " <> p1)
  io.println("p1: " <> p2)
}

pub fn sort(input: List(Int)) -> List(#(Int, Int)) {
  let len = list.length(input)
  list.index_map(input, fn(v, i) { #(v, len - i) })
  |> list.sort(fn(a, b) {
    case int.compare(b.0, a.0) {
      order.Eq -> int.compare(b.1, a.1)
      ord -> ord
    }
  })
}

pub fn find_digits(input: List(#(Int, Int)), n: Int) -> Int {
  do_find_digits(input, n, [])
  |> list.fold_right(0, fn(acc, v) { acc * 10 + v })
}

pub fn do_find_digits(
  input: List(#(Int, Int)),
  n: Int,
  acc: List(Int),
) -> List(Int) {
  case n {
    0 -> acc
    _ -> {
      let assert Ok(#(v, i)) = list.find(input, fn(x) { x.1 >= n })
      do_find_digits(list.filter(input, fn(x) { x.1 < i }), n - 1, [v, ..acc])
    }
  }
}
