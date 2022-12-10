require "../../helpers/input"

module Day10
  NOOP = "noop"
  ADDX = "addx "

  def self.part1
    input = Input.new("../input/in")

    pixels(input).each_with_index(1).select { |v, i| i % 40 == 20 }.sum { |i, v| i * v }
  end

  def self.part2
    input = Input.new("../input/in")

    pixels(input).each_slice(40).map(&.map_with_index { |v, i| (v - 1..v + 1).includes?(i) ? '🎅' : '🎄' }.join).join('\n')
  end

  private def self.pixels(input)
    input.lines(cleanup: true).each_with_object([] of Int32) do |instruction, instructions|
      instructions << 0
      instructions << instruction[ADDX.size..].to_i if instruction.starts_with?(ADDX)
    end.accumulate(1)
  end
end

puts "Part 1 : #{Day10.part1}"

puts "Part 2 : \n#{Day10.part2}"
