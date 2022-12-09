require "../../helpers/input"

module Day09
  enum Direction
    Right
    Up
    Left
    Down
  end

  DIRECTIONS = {Direction::Right => {1, 0}, Direction::Up => {0, -1}, Direction::Left => {-1, 0}, Direction::Down => {0, 1}}
  ORIGIN     = {0, 0}

  alias Coord = Tuple(Int32, Int32)

  def self.part1
    solve(Input.new("../input/in"), 2)
  end

  def self.part2
    solve(Input.new("../input/in"), 10)
  end

  private def self.solve(input, size)
    input = Input.new("../input/in")

    rope = Array(Coord).new(size, ORIGIN)
    visited = Set(Coord).new

    parse_moves(input).each do |(dir, steps)|
      dx, dy = DIRECTIONS[dir]

      steps.to_i.times do
        rope.map_with_index! do |(cx, cy), i|
          next {cx + dx, cy + dy} if i == 0

          kx, ky = rope[i - 1]
          dxx = cx - kx
          dyy = cy - ky

          next {cx, cy} if [dxx, dyy].map(&.abs).all?(&.<=(1))

          {cx - dxx.sign, cy - dyy.sign}
        end

        visited << rope.last
      end
    end

    visited.size
  end

  private def self.parse_moves(input)
    input.lines(cleanup: true).map do |line|
      raw_dir, raw_steps = line.split

      dir = case raw_dir
            when "D" then Direction::Down
            when "U" then Direction::Up
            when "L" then Direction::Left
            when "R" then Direction::Right
            end

      {dir, raw_steps.to_i}
    end
  end
end

puts "Part 1 : #{Day09.part1}"

puts "Part 2 : #{Day09.part2}"
