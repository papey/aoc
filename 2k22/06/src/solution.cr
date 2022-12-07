require "../../helpers/input"

module Day06
  PKT_SIZE =  4
  MSG_SIZE = 14

  def self.part1
    input = Input.new("../input/in")

    solve(input.lines.first.each_char, PKT_SIZE)
  end

  def self.part2
    input = Input.new("../input/in")

    solve(input.lines.first.each_char, MSG_SIZE)
  end

  def self.solve(dataframe, size)
    dataframe.cons(size).index { |part| part.uniq.size == size }.not_nil! + size
  end
end

puts "Part 1 : #{Day06.part1}"

puts "Part 2 : #{Day06.part2}"
