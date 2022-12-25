require "../../helpers/input"
require "math"

module Day25
  BASE = 5

  def self.part1
    number = Input.new("../input/in").lines(cleanup: true).sum do |line|
      line.chars.reverse.each_with_index.reduce(0.to_i64) do |acc, (ch, index)|
        n = case ch
            when '-'
              -1
            when '='
              -2
            else
              ch.to_i
            end

        acc + n.to_i64 * (BASE.to_i64 ** index)
      end
    end

    output = [] of Char

    until number == 0
      rem = number % BASE
      number //= BASE
      ch = case rem
           when 0
             '0'
           when 1
             '1'
           when 2
             '2'
           when 3
             number += 1
             '='
           when 4
             number += 1
             '-'
           else
             raise "Unreachable !"
           end
      output.unshift(ch)
    end

    output.join("")
  end

  def self.part2
    "⭐"
  end
end

puts "Part 1 : #{Day25.part1}"

puts "Part 2 : #{Day25.part2}"
