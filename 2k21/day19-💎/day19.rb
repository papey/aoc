# a complete mess made readable thanks to https://github.com/ahorner/advent-of-code/blob/main/lib/2021/19.rb

require 'set'

def parse(content)
  content.split("\n\n").map do |scan|
    _, *scans = scan.split("\n")
    scans.map { |l| l.split(',').map(&:to_i) }
  end
end

def discover(data)
  scanners = parse(data)

  done = Set.new
  positions = { 0 => [0, 0, 0] }
  beacons = { 0 => Set.new(scanners[0]) }

  until positions.count == scanners.count
    scanners.each_index do |i|
      next if positions[i]

      positions.keys.each do |j|
        done.include?([i, j]) ? next : done << [i, j]

        position, scans = search(beacons[j], scanners[i])

        next unless position

        positions[i] = position
        beacons[i] = Set.new(scans)
      end
    end
  end

  [positions, beacons]
end

class Scanner
  ROTATIONS = [0, 1, 2].permutation.to_a.freeze
  DIRECTIONS = [1, -1].repeated_permutation(3).to_a.freeze

  attr_reader :scans

  def initialize(scans)
    @scans = scans
  end

  def each_rotations
    ROTATIONS.each do |(x, y, z)|
      DIRECTIONS.each do |(dx, dy, dz)|
        yield scans.map { |pos| [pos[x] * dx, pos[y] * dy, pos[z] * dz] }
      end
    end
  end
end

MIN_COMMON = 12

def search(a, b)
  Scanner.new(b).each_rotations do |rotations|
    a.each do |(ax, ay, az)|
      rotations.each do |(bx, by, bz)|
        ox = bx - ax
        oy = by - ay
        oz = bz - az
        beacons = rotations.map { |x, y, z| [x - ox, y - oy, z - oz] }

        return [[ox, oy, oz], beacons] if beacons.count { |beacon| a.include?(beacon) } >= MIN_COMMON
      end
    end
  end

  [nil, nil]
end

positions, beacons = discover(File.read('inputs/input.txt'))

puts "Part 1: #{beacons.values.inject(:+).count}"

max = positions.values.combination(2).map do |a, b|
  a.zip(b).sum { |i, j| (i - j).abs }
end.max

puts "Part 2: #{max}"
