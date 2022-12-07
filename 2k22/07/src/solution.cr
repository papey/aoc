require "../../helpers/input"

module Day07
  def self.part1
    lines = Input.new("../input/in").split(cleanup: true)
    sizes = [] of Int32

    explore(lines, sizes)

    sizes.select(&.<=(100000)).sum
  end

  DISK_SIZE   = 70000000
  DISK_NEEDED = 30000000

  def self.part2
    lines = Input.new("../input/in").split(cleanup: true)
    sizes = [] of Int32

    used = explore(lines, sizes)

    sizes.select(&.>(DISK_NEEDED - (DISK_SIZE - used))).min
  end

  def self.explore(lines, sizes)
    size = 0

    while line = lines.shift?
      case
      when line =~ /^\$ cd \.\./
        sizes << size
        return size
      when line =~ /^\$ cd/
        size += explore(lines, sizes)
      when line =~ /^\d+/
        size += line.split.first.to_i
      end
    end

    size
  end
end

puts "Part 1 : #{Day07.part1}"

puts "Part 2 : #{Day07.part2}"
