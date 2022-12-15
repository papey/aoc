require "../../helpers/input"

module Day15
  INPUT_REGEX = /Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/

  Y_TARGET = 2000000

  def self.part1
    sensors, beacons = parse(Input.new("../input/in"))

    xmin = Int32::MAX
    xmax = Int32::MIN

    sensors.each do |sensor|
      next unless Y_TARGET.in?(sensor.y - sensor.r..sensor.y + sensor.r)

      delta = sensor.r - (Y_TARGET - sensor.y).abs

      xmin = {xmin, sensor.x - delta}.min
      xmax = {xmax, sensor.x + delta}.max
    end

    (xmin..xmax).size - beacons[Y_TARGET].count { |xx| xx.in?(xmin..xmax) }
  end

  TARGET_RANGE = 0..4000000

  def self.part2
    sensors, _beacons = parse(Input.new("../input/in"))

    sensors.each do |sensor|
      sensor.r.times do |dx|
        dy = sensor.r - dx + (dx == 0 ? 0 : 1)

        [-1, +1].each do |dir|
          xx = sensor.x + dx * dir
          yy = sensor.y + dy * dir

          next if !xx.in?(TARGET_RANGE) || !yy.in?(TARGET_RANGE)

          return 4000000_i64 * xx + yy if sensors.none?(&.detects?(xx, yy))
        end
      end
    end
  end

  private def self.parse(input)
    sensors = [] of Sensor
    beacons = Hash(Int32, Set(Int32)).new { |hash, key| hash[key] = Set(Int32).new }

    input.raw.scan(INPUT_REGEX).each do |match|
      sx, sy, bx, by = match.captures.compact_map(&.try &.to_i)

      sensors << Sensor.new(sx, sy, (bx - sx).abs + (by - sy).abs)
      beacons[by] << bx
    end

    {sensors, beacons}
  end

  class Sensor
    getter x : Int32
    getter y : Int32
    getter r : Int32

    def initialize(@x, @y, @r)
    end

    def detects?(xx, yy)
      (xx - x).abs + (yy - y).abs <= r
    end
  end
end

puts "Part 1 : #{Day15.part1}"

puts "Part 2 : #{Day15.part2}"
