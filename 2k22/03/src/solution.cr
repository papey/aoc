require "../../helpers/input"

module Day03
  def self.part1
    input = Input.new("../input/in")

    input.split(cleanup: true).sum do |rucksack|
      badge = rucksack.chars.each_slice(rucksack.size // 2).reduce { |common, part| common & part }.first
      priority(badge)
    end
  end

  def self.part2
    input = Input.new("../input/in")

    input.split(cleanup: true).each_slice(3).sum do |group|
      badge = group.map(&.chars).reduce() { |common, rucksack| common & rucksack }.first
      priority(badge)
    end
  end

  private def self.priority(badge)
    badge <= 'Z' ? badge - 'A' + ('z' - 'a') : badge - 'a' + 1
  end
end

puts "Part 1 : #{Day03.part1}"

puts "Part 2 : #{Day03.part2}"
