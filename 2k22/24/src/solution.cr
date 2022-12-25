require "../../helpers/input"

module Day24
  def self.part1
    storm, borders, boundaries = parse(Input.new("../input/in"))

    xbound, ybound = boundaries

    bfs(
      Pos.new(1, 0),
      Pos.new(xbound[1] - 1, ybound[1]),
      storms(storm, {xbound[1] - 1, ybound[1] - 1}),
      borders,
      0,
      boundaries
    )
  end

  def self.part2
    storm, borders, boundaries = parse(Input.new("../input/in"))

    xbound, ybound = boundaries

    storms = storms(storm, {xbound[1] - 1, ybound[1] - 1})
    start = Pos.new(1, 0)
    goal = Pos.new(xbound[1] - 1, ybound[1])

    go = bfs(
      start,
      goal,
      storms,
      borders,
      0,
      boundaries
    )

    goback = bfs(
      goal,
      start,
      storms,
      borders,
      go,
      boundaries
    )

    bfs(
      start,
      goal,
      storms,
      borders,
      goback,
      boundaries
    )
  end

  def self.bfs(start, goal, storms, borders, cycle, boundaries)
    queue = [{start, cycle}]
    visited = Set({Pos, Int32}).new

    until queue.empty?
      pos, time = queue.shift

      return time - 1 if pos == goal

      next if visited.includes?({pos, time % storms.size})

      visited << {pos, time % storms.size}

      neighbors(pos, storms[time % storms.size], borders, start, boundaries)
        .each { |neighbor| queue << {neighbor, time + 1} }
    end

    Int32::MAX
  end

  DIRECTIONS = [Pos.new(0, 0), Pos.new(0, -1), Pos.new(0, 1), Pos.new(-1, 0), Pos.new(1, 0)]

  def self.neighbors(pos, storm, borders, start, boundaries)
    xbound, ybound = boundaries

    DIRECTIONS.compact_map do |delta|
      candidate = pos + delta

      next if borders.includes?(candidate) || storm.includes?(candidate) || candidate.outside?(boundaries)

      candidate
    end
  end

  def self.parse(input)
    ymax = 0
    xmax = 0

    storm, borders = input.lines(cleanup: true)
      .each_with_index
      .each_with_object({Hash(Pos, Pos).new, Set(Pos).new}) do |(line, y), (storm, borders)|
        ymax = {ymax, y}.max

        line.chars.each_with_index do |ch, x|
          xmax = {xmax, x}.max

          case ch
          when '^'
            storm[Pos.new(x, y)] = Pos.new(0, -1)
          when '>'
            storm[Pos.new(x, y)] = Pos.new(1, 0)
          when 'v'
            storm[Pos.new(x, y)] = Pos.new(0, 1)
          when '<'
            storm[Pos.new(x, y)] = Pos.new(-1, 0)
          when '#'
            borders << Pos.new(x, y)
          else
          end
        end
      end

    {storm, borders, { {0, xmax}, {0, ymax} }}
  end

  def self.storms(storm, storm_size)
    w, h = storm_size

    all = Hash(Int32, Set(Pos)).new

    (0..).each do |time|
      next_storm = storm.each_with_object(Set(Pos).new) do |(origin, direction), acc|
        x = 1 + (origin.x - 1 + (direction.x * time)) % w
        y = 1 + (origin.y - 1 + (direction.y * time)) % h
        acc << Pos.new(x, y)
      end

      break all if all.values.includes?(next_storm)

      all[time] = next_storm
    end
  end

  struct Pos
    getter x : Int32
    getter y : Int32

    def initialize(@x, @y)
    end

    def +(other)
      Pos.new(x + other.x, y + other.y)
    end

    def ==(other)
      x == other.x && y == other.y
    end

    def inside?(boundaries)
      xbound, ybound = boundaries

      xbound[0] <= x <= xbound[1] && ybound[0] <= y <= ybound[1]
    end

    def outside?(boundaries)
      !inside?(boundaries)
    end
  end
end

puts "Part 1 : #{Day24.part1}"

puts "Part 2 : #{Day24.part2}"
