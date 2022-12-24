require "../../helpers/input"

module Day23
  def self.part1
    state = parse(Input.new("../input/in"))

    simulate(state, 10)

    xmin, xmax = state.minmax_of(&.x)
    ymin, ymax = state.minmax_of(&.y)

    (xmax - xmin + 1) * (ymax - ymin + 1) - state.size
  end

  def self.part2
    state = parse(Input.new("../input/in"))

    simulate(state, nil)
  end

  struct Pos
    getter x : Int32
    getter y : Int32

    def initialize(@x, @y)
    end

    def +(other)
      Pos.new(x + other.x, y + other.y)
    end

    def clone
      Pos.new(x, y)
    end
  end

  MOVES = [
    {Pos.new(0, -1), Pos.new(1, -1), Pos.new(-1, -1)},
    {Pos.new(0, 1), Pos.new(1, 1), Pos.new(-1, 1)},
    {Pos.new(-1, 0), Pos.new(-1, 1), Pos.new(-1, -1)},
    {Pos.new(1, 0), Pos.new(1, 1), Pos.new(1, -1)},
  ]

  ADJACENT = MOVES.each_with_object(Set(Pos).new) { |moves, acc| moves.each { |move| acc << move } }

  def self.parse(input)
    input.lines(cleanup: true).each_with_index.each_with_object(Set(Pos).new) do |(line, y), acc|
      line.chars.each_with_index do |ch, x|
        next unless ch == '#'

        acc << Pos.new(x, y)
      end
    end
  end

  def self.simulate(state, runs)
    moves = MOVES.clone

    range = runs.nil? ? (1..) : (1..runs)

    range.each do |round|
      candidates = Hash(Pos, Array(Pos)).new

      state.each do |pos|
        next if ADJACENT.none? { |delta| state.includes?(pos + delta) }

        move = moves.find { |deltas| deltas.none? { |delta| state.includes?(pos + delta) } }

        next if move.nil?

        delta = move.first

        candidate = pos + delta
        candidates[candidate] ||= [] of Pos
        candidates[candidate].push(pos)
      end

      moved = false

      candidates.each do |candidate, elves|
        next if elves.size != 1

        moved = true
        state.delete(elves.first)
        state << candidate
      end

      return round unless moved

      moves << moves.shift
    end
  end
end

puts "Part 1 : #{Day23.part1}"

puts "Part 2 : #{Day23.part2}"
