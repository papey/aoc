require "../../helpers/input"

module Day18
  enum Kind
    Lava
    Air
  end

  def self.part1
    input = Input.new("../input/in")

    cubes = input.lines(cleanup: true).each_with_object(Hash(Pos, Kind).new(Kind::Air)) do |line, acc|
      x, y, z = line.split(",").map(&.to_i)
      acc[Pos.new(x, y, z)] = Kind::Lava
    end

    cubes.keys.sum do |cube|
      NEIGHBORS.each.sum do |neighbor|
        cubes.has_key?(cube + neighbor) ? 0 : 1
      end
    end
  end

  def self.part2
    input = Input.new("../input/in")

    max = Int32::MIN
    min = Int32::MAX

    cubes = input.lines(cleanup: true).each_with_object(Hash(Pos, Kind).new(Kind::Air)) do |line, acc|
      x, y, z = line.split(",").map(&.to_i)

      max = {max, x, y, z}.max
      min = {min, x, y, z}.min

      acc[Pos.new(x, y, z)] = Kind::Lava
    end

    max += 1
    min -= 1
    queue = [Pos.new(min, min, min)]

    while current = queue.pop?
      next if current.outside?(min, max) || cubes.has_key?(current)

      NEIGHBORS.each { |delta| queue << current + delta }
      cubes[current] = Kind::Air
    end

    cubes.each.sum do |pos, kind|
      next 0 if kind.lava?

      NEIGHBORS.count do |delta|
        cubes[pos + delta].lava?
      end
    end
  end

  struct Pos
    getter x : Int32
    getter y : Int32
    getter z : Int32

    def initialize(@x, @y, @z)
    end

    def +(other : Pos)
      Pos.new(x + other.x, y + other.y, z + other.z)
    end

    def outside?(min, max)
      {x, y, z}.any? { |v| v < min || v > max }
    end
  end

  NEIGHBORS = {
    Pos.new(1, 0, 0), Pos.new(-1, 0, 0),
    Pos.new(0, 1, 0), Pos.new(0, -1, 0),
    Pos.new(0, 0, 1), Pos.new(0, 0, -1),
  }
end

puts "Part 1 : #{Day18.part1}"

puts "Part 2 : #{Day18.part2}"
