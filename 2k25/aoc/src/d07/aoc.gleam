import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/set
import gleam/string
import parser/parser

pub fn main() -> Nil {
  let assert Ok(input) = parser.parse("./inputs/d07.txt")

  let assert [beams, ..splitters] =
    input
    |> list.sized_chunk(2)
    |> list.map(fn(input_chunk) {
      let assert [line, _] = input_chunk

      string.to_graphemes(line)
      |> list.index_fold([], fn(acc, char, i) {
        case char {
          "." -> acc
          _ -> [i, ..acc]
        }
      })
    })
    |> list.map(set.from_list)

  let p1 =
    list.fold(splitters, #(beams, 0), fn(acc, current_splitters) {
      let #(beams, split) = acc

      set.intersection(beams, current_splitters)
      |> set.to_list
      |> list.fold(#(beams, split), fn(acc, splitter) {
        let #(beams, split) = acc
        #(
          beams
            |> set.delete(splitter)
            |> set.insert(splitter - 1)
            |> set.insert(splitter + 1),
          split + 1,
        )
      })
    })

  io.println("p1: " <> int.to_string(p1.1))

  let assert Ok(start) = set.to_list(beams) |> list.first
  let init = dict.new() |> dict.insert(start, 1)

  let p2 =
    splitters
    |> list.fold(init, fn(acc, current_splitters) {
      current_splitters
      |> set.to_list
      |> list.fold(acc, fn(acc, splitter) {
        case dict.get(acc, splitter) {
          Ok(count) -> {
            list.fold([-1, 1], acc, fn(acc, d) {
              acc
              |> dict.upsert(splitter + d, fn(prev) {
                case prev {
                  Some(v) -> v + count
                  None -> count
                }
              })
            })
            |> dict.delete(splitter)
          }
          _ -> acc
        }
      })
    })
    |> dict.values()
    |> int.sum()

  io.println("p2: " <> int.to_string(p2))
}
