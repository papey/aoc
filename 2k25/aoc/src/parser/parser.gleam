import gleam/list
import gleam/result
import gleam/string

import simplifile

pub fn parse(path: String) -> Result(List(String), simplifile.FileError) {
  simplifile.read(path)
  |> result.map(fn(content) {
    string.split(content, "\n")
    |> list.filter(fn(line) { !string.is_empty(line) })
  })
}
