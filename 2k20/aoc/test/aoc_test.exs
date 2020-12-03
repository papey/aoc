defmodule AOCTest do
  use ExUnit.Case
  doctest AOC

  test "Day 1" do
    assert AOC.D1.run1() == 996_996
    assert AOC.D1.run2() == 9_210_402
  end

  test "Day 2" do
    assert AOC.D2.run1() == 393
    assert AOC.D2.run2() == 690
  end

  test "Day 3" do
    assert AOC.D3.run1() == 195
    assert AOC.D3.run2() == 3_772_314_000
  end
end
