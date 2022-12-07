require "../../helpers/input"

module Day04
  def self.part1
    input = Input.new("../input/in")

    input.lines(cleanup: true).count do |sections|
      a_low, a_high, b_low, b_high = parse(sections)
      a_low <= b_low && b_high <= a_high || b_low <= a_low && a_high <= b_high
    end
  end

  def self.part2
    input = Input.new("../input/in")

    input.lines(cleanup: true).count do |sections|
      a_low, a_high, b_low, b_high = parse(sections)
      a_low <= b_low <= a_high || b_low <= a_low <= b_high
    end
  end

  def self.parse(line)
    /(\d+)-(\d+),(\d+)-(\d+)/.match(line).try &.captures.compact_map { |bound| bound.try &.to_i } || [] of Int32
  end
end

puts "Part 1 : #{Day04.part1}"

puts "Part 2 : #{Day04.part2}"
