import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/set
import gleam/string
import parser/parser

pub type Point {
  Point(x: Int, y: Int)
}

pub type Grid =
  set.Set(Point)

pub fn main() -> Nil {
  let assert Ok(lines) = parser.parse("./inputs/d04.txt")

  let grid = build_grid(lines)

  let p1 =
    grid
    |> set.to_list
    |> list.filter(is_accessible(_, grid))
    |> list.length
    |> int.to_string

  io.println("p1: " <> p1)

  let p2 = list.fold(set.to_list(grid), #(grid, 0), explore)

  io.println("p2: " <> int.to_string(p2.1))
}

pub fn neighbors(pos: Point) -> List(Point) {
  let Point(x, y) = pos
  [
    Point(x - 1, y),
    Point(x + 1, y),
    Point(x, y - 1),
    Point(x, y + 1),
    Point(x - 1, y - 1),
    Point(x + 1, y - 1),
    Point(x - 1, y + 1),
    Point(x + 1, y + 1),
  ]
}

fn explore(state: #(Grid, Int), pos: Point) -> #(Grid, Int) {
  let #(grid, accessible) = state

  let should_explore = set.contains(grid, pos) && is_accessible(pos, grid)

  case should_explore {
    False -> state
    True -> {
      list.fold(
        neighbors(pos),
        #(set.delete(grid, pos), accessible + 1),
        explore,
      )
    }
  }
}

const max_neighbors: Int = 4

pub fn is_accessible(pos: Point, grid: Grid) -> Bool {
  list.filter(neighbors(pos), fn(neighbor) { set.contains(grid, neighbor) })
  |> list.length
  < max_neighbors
}

pub fn build_grid(lines: List(String)) -> Grid {
  list.index_map(lines, fn(row, y) {
    list.index_map(string.to_graphemes(row), fn(cell, x) {
      case cell {
        "@" -> option.Some(Point(x, y))
        _ -> option.None
      }
    })
  })
  |> list.flatten
  |> list.fold(set.new(), fn(acc, cell) {
    case cell {
      option.Some(value) -> set.insert(acc, value)
      option.None -> acc
    }
  })
}
