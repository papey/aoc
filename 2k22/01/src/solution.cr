require "../../helpers/input"

module Day01
  def self.part1
    input = Input.new("../input/in")

    by_elves(input.lines).first
  end

  def self.part2
    input = Input.new("../input/in")

    by_elves(input.lines)[..2].sum
  end

  def self.by_elves(entries)
    tracked = entries.each_with_object([0]) do |line, tracker|
      if line.empty?
        tracker << 0
        next
      end

      tracker[-1] += line.to_i
    end

    tracked.sort_by { |v| -v }
  end
end

puts "Part 1 : #{Day01.part1}"

puts "Part 2 : #{Day01.part2}"
