# frozen_string_literal: true

module Day13
  def self.part1
    parse
      .each_slice(2)
      .with_index(1)
      .sum { |(a, b), index| cmp(a, b) == -1 ? index : 0 }
  end

  def self.part2
    extra_pkt1 = [[2]]
    extra_pkt2 = [[6]]

    packets = parse

    packets << extra_pkt1
    packets << extra_pkt2

    packets.sort! { |a, b| cmp(a, b) }

    packets
      .each
      .with_index(1)
      .filter_map { |v, index| index if [extra_pkt1, extra_pkt2].include?(v) }
      .reduce(:*)
  end

  class << self
    private

    def cmp(a, b)
      case [a.class, b.class]
      when [Integer, Integer]
        return a <=> b
      when [Array, Integer]
        b = [b]
      when [Integer, Array]
        a = [a]
      end

      a.zip(b) do |va, vb|
        next if vb.nil?

        ret = cmp(va, vb)

        return ret if ret != 0
      end

      a.size <=> b.size
    end

    def parse
      File
        .readlines("../input/in")
        .map(&:chomp)
        .reject(&:empty?)
        .map { |line| eval line }
    end
  end
end

puts "Part 1: #{Day13.part1}"

puts "Part 2: #{Day13.part2}"
