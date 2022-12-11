# frozen_string_literal: true

module Day11
  def self.part1
    monkeys = init_monkeys(File.read("../input/in"))

    solve(monkeys, 20) { |value| value / 3 }
  end

  def self.part2
    monkeys = init_monkeys(File.read("../input/in"))

    mod = monkeys.map(&:level).reduce(:*)

    solve(monkeys, 10_000) { |value| value % mod }
  end

  def self.solve(monkeys, rounds)
    inspected_by_monkeys =
      rounds
        .times
        .each_with_object(Hash.new(0)) do |_round, hash|
          monkeys.each do |monkey|
            hash[monkey.id] += monkey.holds

            while monkey.items?
              worry = yield monkey.worries.call

              monkeys[monkey.target(worry)].receive(worry)
            end
          end
        end

    inspected_by_monkeys.values.sort[(monkeys.length - 2)..].reduce(:*)
  end

  def self.init_monkeys(input)
    input.split("\n\n").map { |raw_monkey| Monkey.from_input(raw_monkey) }
  end

  class Monkey
    # funny time
    MONKEY_REGEX =
      /^Monkey (?<id>\d+):
  Starting items: (?<items>[\d, ]+)
  Operation: new = (?<operation>old [*+] \w+)
  Test: divisible by (?<level>\d+)
    If true: throw to monkey (?<target_if_true>\d+)
    If false: throw to monkey (?<target_if_false>\d+)/.freeze

    attr_reader :worries, :id, :level

    def self.from_input(raw_monkey)
      matches = raw_monkey.match(MONKEY_REGEX)

      Monkey.new(
        matches[:id].to_i,
        matches[:items].split(",").map(&:to_i),
        matches[:operation],
        matches[:level].to_i,
        matches[:target_if_true].to_i,
        matches[:target_if_false].to_i
      )
    end

    def initialize(id, items, operation, level, target_if_true, target_if_false)
      @id = id
      @items = items
      # here comes the fun
      @worries =
        proc do
          old = @items.pop
          eval operation
        end
      @level = level
      @target_if_true = target_if_true
      @target_if_false = target_if_false
    end

    def items?
      !items.empty?
    end

    def debug
      items
    end

    def holds
      items.length
    end

    def target(worry)
      (worry % level).zero? ? target_if_true : target_if_false
    end

    def receive(item)
      items << item
    end

    private

    attr_reader :items, :target_if_true, :target_if_false
  end
end

puts "Part 1: #{Day11.part1}"

puts "Part 2: #{Day11.part2}"
