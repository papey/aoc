require "../../helpers/input"

module Day12
  START = 'S'
  END   = 'E'

  alias Pos = Tuple(Int32, Int32)
  alias Map = Array(Array(Char))

  def self.part1
    map, start, destination = init_map!(Input.new("../input/in"))

    has_reached_destination = ->(map : Map, cur : Pos, dst : Pos) : Bool { cur == dst }

    # we actually search backward from destination to start
    bfs(map, destination, start, has_reached_destination)
  end

  def self.part2
    map, start, destination = init_map!(Input.new("../input/in"))

    has_reached_destination = Proc(Map, Pos, Pos, Bool).new do |map, cur, dest|
      cy, cx = cur
      map[cy][cx] == 'a'
    end

    # we actually search backward from destination to start
    bfs(map, destination, start, has_reached_destination)
  end

  def self.init_map!(input)
    map = input.lines(cleanup: true).map(&.chars)

    s_y = map.index!(&.includes?(START))
    s_x = map[s_y].index!(START)
    map[s_y][s_x] = 'a'

    e_y = map.index!(&.includes?(END))
    e_x = map[e_y].index!(END)
    map[e_y][e_x] = 'z'

    {map, {s_y, s_x}, {e_y, e_x}}
  end

  def self.bfs(map, start, destination, has_reached_destination)
    w = map[0].size
    h = map.size

    queue = [start]
    visited = {start => 0}

    until queue.empty?
      cy, cx = current = queue.shift

      return visited[current] if has_reached_destination.call(map, current, destination)

      from = map[cy][cx]

      neighbors(w, h, {cy, cx}).each do |neighbor|
        ny, nx = neighbor
        to = map[ny][nx]

        next unless from - to <= 1

        if !visited.has_key?(neighbor)
          queue << neighbor
          visited[neighbor] = visited[current] + 1
        end
      end
    end

    raise "Destination not found"
  end

  def self.neighbors(w, h, pos)
    y, x = pos

    [
      {y, x - 1},
      {y, x + 1},
      {y - 1, x},
      {y + 1, x},
    ].select { |yy, xx| (0 <= yy < h) && (0 <= xx < w) }
  end
end

puts "Part 1 : #{Day12.part1}"

puts "Part 2 : #{Day12.part2}"
