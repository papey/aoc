require "../../helpers/input"

module Day22
  def self.part1
    boundaries, map, instructions = parse(Input.new("../input/in"))

    position : Pos = {(0..boundaries[0]).find! { |x| map.has_key?({x, 0}) && map[{x, 0}].floor? }, 0}
    direction = Direction::East

    instructions.each do |instruction|
      case instruction
      when Move
        (0...instruction.steps).each do |test|
          candidate = move(position, direction, boundaries, map)

          break if map[candidate].rock?

          position = candidate
        end
      when Turn
        case instruction
        when Turn::Clockwise
          direction = Direction.new((direction.value + 1) % MOVES.size)
        when Turn::Counterclockwise
          direction = Direction.new((direction.value - 1) % MOVES.size)
        end
      end
    end

    1000 * (position[1] + 1) + 4 * (position[0] + 1) + direction.value
  end

  SIZE = 50

  def self.part2
    boundaries, map, instructions = parse(Input.new("../input/in"))

    position : Pos = {(0..boundaries[0]).find! { |x| map.has_key?({x, 0}) && map[{x, 0}].floor? }, 0}
    direction = Direction::East

    edges = SIZE.times
      .each_with_object(Hash(Tuple(Pos, Direction), Tuple(Pos, Direction)).new) do |i, edges|
        # A -> D
        edges[{ {50 - 1, i}, Direction::West }] = { {0, 149 - i}, Direction::East }
        # D -> A
        edges[{ {-1, 100 + i}, Direction::West }] = { {50, 49 - i}, Direction::East }

        # A -> F
        edges[{ {50 + i, -1}, Direction::North }] = { {0, 150 + i}, Direction::East }
        # F -> A
        edges[{ {-1, 150 + i}, Direction::West }] = { {50 + i, 0}, Direction::South }

        # C -> D
        edges[{ {50 - 1, 50 + i}, Direction::West }] = { {i, 100}, Direction::South }
        # D -> C
        edges[{ {i, 100 - 1}, Direction::North }] = { {50, 50 + i}, Direction::East }

        # C -> B
        edges[{ {99 + 1, 50 + i}, Direction::East }] = { {100 + i, 49}, Direction::North }
        # B -> C
        edges[{ {100 + i, 49 + 1}, Direction::South }] = { {99, 50 + i}, Direction::West }

        # B -> F
        edges[{ {100 + i, -1}, Direction::North }] = { {i, 199}, Direction::North }
        # F -> B
        edges[{ {i, 199 + 1}, Direction::South }] = { {100 + i, 0}, Direction::South }

        # E -> B
        edges[{ {99 + 1, 100 + i}, Direction::East }] = { {149, 49 - i}, Direction::West }
        # B -> E
        edges[{ {149 + 1, i}, Direction::East }] = { {99, 149 - i}, Direction::West }

        # E -> F
        edges[{ {50 + i, 149 + 1}, Direction::South }] = { {49, 150 + i}, Direction::West }
        # F -> E
        edges[{ {49 + 1, 150 + i}, Direction::East }] = { {50 + i, 149}, Direction::North }
      end

    instructions.each.with_index(2) do |instruction, index|
      case instruction
      when Move
        (0...instruction.steps).each do |test|
          candidate, next_direction = move3D(position, direction, boundaries, map, edges)

          if map[candidate].rock?
            break
          end

          position = candidate
          direction = next_direction
        end
      when Turn
        case instruction
        when Turn::Clockwise
          direction = Direction.new((direction.value + 1) % MOVES.size)
        when Turn::Counterclockwise
          direction = Direction.new((direction.value - 1) % MOVES.size)
        end
      end
    end

    1000 * (position[1] + 1) + 4 * (position[0] + 1) + direction.value
  end

  def self.parse(input)
    raw_map, raw_instructions = input.raw.split("\n\n")

    xmax = Int32::MIN
    ymax = 0

    map = raw_map.split("\n")
      .each
      .with_index
      .each_with_object({} of Pos => Tile) do |(line, row), acc|
        ymax += 1

        line.chars.each_with_index do |ch, col|
          next if ch == ' '

          xmax = col if col > xmax

          acc[{col, row}] = ch == '.' ? Tile::Floor : Tile::Rock
        end
      end

    instructions = raw_instructions.scan(/(\d+|R|L)/).map do |match|
      case match[1]
      when "R"
        Turn::Clockwise
      when "L"
        Turn::Counterclockwise
      else
        Move.new(match[1].to_i)
      end
    end

    { {xmax, ymax}, map, instructions }
  end

  def self.move(current, direction, boundaries, map)
    candidate = {current[0] + MOVES[direction.value][0], current[1] + MOVES[direction.value][1]}

    return candidate if map.has_key?(candidate)

    x_candidate, y_candidate = candidate

    case direction
    when Direction::East
      x_overlap = 0.to(boundaries[0]).find! { |x| map.has_key?({x, y_candidate}) }
      {x_overlap, y_candidate}
    when Direction::South
      y_overlap = 0.to(boundaries[1]).find! { |y| map.has_key?({x_candidate, y}) }
      {x_candidate, y_overlap}
    when Direction::West
      x_overlap = boundaries[0].to(0).find! { |x| map.has_key?({x, y_candidate}) }
      {x_overlap, y_candidate}
    when Direction::North
      y_overlap = boundaries[1].to(0).find! { |y| map.has_key?({x_candidate, y}) }
      {x_candidate, y_overlap}
    else
      raise "Unreachable !"
    end
  end

  def self.move3D(current, direction, boundaries, map, edges)
    candidate = {current[0] + MOVES[direction.value][0], current[1] + MOVES[direction.value][1]}

    if edges.has_key?({candidate, direction})
      edges[{candidate, direction}]
    else
      {candidate, direction}
    end
  end

  def self.debug(map, xmax, ymax)
    (0..ymax).each do |y|
      (0..xmax).each do |x|
        reachable = map.has_key?({x, y})

        if !reachable
          print ' '
          next
        end

        case map[{x, y}]
        when Tile::Rock
          print "#"
        when Tile::Floor
          print "."
        end
      end

      puts
    end
  end

  alias Pos = Tuple(Int32, Int32)

  MOVES = [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]

  enum Direction
    East  = 0
    South = 1
    West  = 2
    North = 3
  end

  enum Tile
    Floor
    Rock
  end

  enum Turn
    Clockwise
    Counterclockwise
  end

  struct Move
    getter steps : Int32

    def initialize(@steps)
    end
  end
end

puts "Part 1 : #{Day22.part1}"

puts "Part 2 : #{Day22.part2}"
