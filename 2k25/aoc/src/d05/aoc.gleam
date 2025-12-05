import gleam/order
import gleam/io
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub type Range {
  Range(s: Int, e: Int)
}

pub fn main() -> Nil {
  let #(ranges, ingredients) = parse("./inputs/d05.txt")

  let p1 = list.filter(ingredients, fn(ing) {
    list.any(ranges, fn(range) {
      ing >= range.s && ing <= range.e
    })
  })
  |> list.length

  io.println("p1: " <> int.to_string(p1))

  let sorted = list.sort(ranges, fn(a, b) {
    case int.compare(a.s, b.s) {
      order.Eq -> int.compare(a.e, b.e)
      other -> other
    }
  })


  let assert [start, .._] = sorted

  // next_cursor = max(e1 + 1 [because inclusive], cursor): maybe we encouter a range that put cursor over current range
  // adjusted_start = max(s1, cursor): account for gaps between ranges
  // l = int.max(e - adjusted_start + 1 [because inclusive], 0): length of current range that is not already covered by previous ranges
  // ⬇️ cursor
  //   |s1...e1|
  //        |s2...e2|
  //                    |s3...e3|
  //                            |s4...e4|
  //                              |s5e5|
  let p2 = list.fold(sorted, #(start.s, 0), fn(acc, range) {
    let #(cursor, count) = acc
    let Range(s, e) = range

    let adjusted_start = int.max(s, cursor)
    let next_cursor = int.max(cursor, e + 1)
    let l = int.max(e - adjusted_start + 1, 0)
    #(next_cursor, count + l)
  })

  io.println("p2: " <> int.to_string(p2.1))
}

fn parse(path: String) -> #(List(Range), List(Int)) {
  let assert Ok(content) = simplifile.read(path)

  let assert Ok(#(raw_ranges, raw_ingredients)) =
    string.split_once(content, "\n\n")

  let assert Ok(ranges) =
    string.split(raw_ranges, "\n")
    |> list.map(fn(line) {
      string.split_once(line, "-")
      |> result.try(fn(res) {
        let #(s, e) = res
        let assert Ok(start) = int.parse(s)
        let assert Ok(end) = int.parse(e)
        Ok(Range(start, end))
      })
    })
    |> result.all

  let ingredients =
    string.split(raw_ingredients, "\n")
    |> list.filter(fn(line) { !string.is_empty(line) })
    |> list.map(fn(line) {
      let assert Ok(num) = int.parse(line)
      num
    })

  #(ranges, ingredients)
}
