defmodule AOCTest do
  use ExUnit.Case
  doctest AOC

  test "Day 1" do
    assert AOC.D1.run1() == 996_996
    assert AOC.D1.run2() == 9_210_402
  end
end
