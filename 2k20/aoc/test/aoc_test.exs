defmodule AOCTest do
  use ExUnit.Case

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

  fields = [
    {"byr", "2002", true},
    {"byr", "2003", false},
    {"hgt", "60in", true},
    {"hgt", "190cm", true},
    {"hgt", "190in", false},
    {"hgt", "190", false},
    {"hcl", "#123abc", true},
    {"hcl", "#123abz", false},
    {"hcl", "123abc", false},
    {"ecl", "brn", true},
    {"ecl", "wat", false},
    {"pid", "000000001", true},
    {"pid", "0123456789", false}
  ]

  for {key, val, expect} <- fields do
    @key key
    @val val
    @expect expect
    test "Day 4: values validation : #{@key} #{@val} #{@expect}" do
      assert AOC.D4.valid_value?(@key, @val) == @expect
    end
  end

  test "Day 4" do
    assert AOC.D4.run1() == 228
    assert AOC.D4.run2() == 175
  end

  test "Day 5" do
    assert AOC.D5.run1() == 926
    assert AOC.D5.run2() == 657
  end

  test "Day 6" do
    assert AOC.D6.run1() == 6310
    assert AOC.D6.run2() == 3193
  end

  test "Day 7" do
    assert AOC.D7.run1() == 326
    assert AOC.D7.run2() == 5635
  end

  test "Day 8" do
    assert AOC.D8.run1() == 1446
    assert AOC.D8.run2() == 1403
  end

  test "Day 9" do
    assert AOC.D9.run1() == 21_806_024
    assert AOC.D9.run2() == 2_986_195
  end

  test "Day 10" do
    assert AOC.D10.run1() == 1984
    assert AOC.D10.run2() == 3_543_369_523_456
  end

  test "Day 11" do
    assert AOC.D11.run1() == 2418
    assert AOC.D11.run2() == 2144
  end

  test "Day 12" do
    assert AOC.D12.run1() == 1133
    assert AOC.D12.run2() == 61053
  end

  test "Day 13" do
    assert AOC.D13.run1() == 370
    assert AOC.D13.run2() == 894_954_360_381_385
  end

  test "Day 14" do
    assert AOC.D14.run1() == 16_003_257_187_056
    assert AOC.D14.run2() == 3_219_837_697_833
  end

  test "Day 15" do
    assert AOC.D15.run1() == 517
    assert AOC.D15.run2() == 1_047_739
  end

  test "Day 16" do
    assert AOC.D16.run1() == 25961
  end
end
