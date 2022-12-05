require "../../helpers/input"

module Day05
  def self.part1
    input = Input.new("../input/in")

    state, instructions = input.raw.split("\n\n")

    cargo = Cargo.from_input(state)

    instructions.split("\n", remove_empty: true).each do |instruction|
      quantity, from, to = parse_instruction(instruction)
      cargo.move(quantity, from, to)
    end

    cargo.heads
  end

  def self.part2
    input = Input.new("../input/in")

    state, instructions = input.raw.split("\n\n")

    cargo = Cargo.from_input(state)

    instructions.split("\n", remove_empty: true).each do |instruction|
      quantity, from, to = parse_instruction(instruction)
      cargo.move(quantity, from, to, reverse: true)
    end

    cargo.heads
  end

  def self.parse_instruction(instruction)
    /move (\d+) from (\d+) to (\d+)/.match(instruction).try &.captures.compact_map { |d| d.try &.to_i } || [] of Int32
  end
end

class Cargo
  @cranes : Array(Array(String))

  def self.from_input(input)
    rows = input.split("\n")[..-2].map do |row|
      row.gsub("    ", "🚫").tr(" []", "").split("")
    end

    state = rows.transpose.map { |crane| crane.reject { |ch| ch == "🚫" } }

    Cargo.new(state)
  end

  def initialize(@cranes)
  end

  def move(quantity, from, to, reverse = false)
    items = @cranes[from - 1].shift(quantity)
    items.reverse! if reverse
    items.each { |item| @cranes[to - 1].unshift(item) }
  end

  def heads
    @cranes.map { |s| s.try &.first || " " }.join
  end
end

puts "Part 1 : #{Day05.part1}"

puts "Part 2 : #{Day05.part2}"
