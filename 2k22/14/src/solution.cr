require "../../helpers/input"

module Day14
  alias Pos = {Int32, Int32}

  ORIGIN = {500, 0}

  MOVES = [{0, 1}, {-1, 1}, {1, 1}]

  def self.part1
    map = init_map(Input.new("../input/in"))

    xmin, xmax = map.map { |x, _y| x }.minmax
    ymax = map.map { |_x, y| y }.max

    ⏳(map, xmin, xmax, ymax)
  end

  def self.part2
    Input.new("../input/in")

    map = init_map(Input.new("../input/in"))

    xmin, xmax = map.map { |x, _y| x }.minmax
    ymax = map.map { |_x, y| y }.max + 2

    ((xmin - 2*ymax)..(xmax + 2*ymax)).each { |xx| map << {xx, ymax} }

    🏜️(map, xmin, xmax, ymax)
  end

  private def self.init_map(input)
    input
      .lines(cleanup: true)
      .each_with_object(Set(Pos).new) do |line, acc|
        line.scan(/(\d+),(\d+)/)
          .map { |match| {match[1].to_i, match[2].to_i} }
          .each_cons_pair do |(x1, y1), (x2, y2)|
            x1.to(x2).each do |xx|
              y1.to(y2).each do |yy|
                acc << {xx, yy}
              end
            end
          end
      end
  end

  private def self.⏳(map, xmin, xmax, ymax)
    (0..).each do |n|
      x, y = ORIGIN

      blocked = while y < ymax
        x, y = MOVES.map { |(dx, dy)| {x + dx, y + dy} }.find { |pos| !map.includes?(pos) } || break true
      end

      return n if !blocked

      map << {x, y}
    end
  end

  private def self.🏜️(map, xmin, xmax, ymax)
    (0..).each do |n|
      break n if map.includes?(ORIGIN)

      x, y = ORIGIN

      while true
        x, y = MOVES.map { |(dx, dy)| {x + dx, y + dy} }.find { |pos| !map.includes?(pos) } || break
      end

      map << {x, y}
    end
  end
end

puts "Part 1 : #{Day14.part1}"

puts "Part 2 : #{Day14.part2}"
