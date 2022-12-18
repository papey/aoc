require "../../helpers/input"

module Day17
  def self.part1
    jets = Input.new("../input/in").lines.first.split("").map_with_index { |move, index| {index, move == "<" ? LEFT : RIGHT} }
    game = Game.new(jets)

    SHAPES.cycle.first(2022).each { |shape| game.play(shape) }

    game.top
  end

  TARGET = 1000000000000

  def self.part2
    jets = Input.new("../input/in").lines.first.split("").map_with_index { |move, index| {index, move == "<" ? LEFT : RIGHT} }

    cycle_start, cycle_end = detect_cycle(jets)

    cycle_len = cycle_end[0] - cycle_start[0]
    cycle_height = cycle_end[1] - cycle_start[1]

    remaining = TARGET - (cycle_start[0] + 1)

    by_pass = remaining // cycle_len
    remaining -= by_pass * cycle_len

    # i know i should reuse the previous game but too many one-off error possible, safety first.
    game = Game.new(jets)
    shapes = SHAPES.cycle

    # redo everything in order to get the same state, huhu
    (0...cycle_start[0]).each { game.play(shapes.next.as(Shape)) }

    remaining.to(0).each { game.play(shapes.next.as(Shape)) }

    by_pass * cycle_height + game.top
  end

  private def self.detect_cycle(jets)
    game = Game.new(jets)

    shapes = SHAPES.cycle
    remaining = TARGET

    cycle = nil

    until cycle
      cycle = game.play(shapes.next.as(Shape), cycle_detection: true)
    end

    cycle
  end

  SHAPES = {
    Shape.new(:hbar, [Pos.new(0, 0), Pos.new(1, 0), Pos.new(2, 0), Pos.new(3, 0)]),
    Shape.new(:plus, [Pos.new(0, 1), Pos.new(1, 0), Pos.new(1, 1), Pos.new(1, 2), Pos.new(2, 1)]),
    Shape.new(:lreversed, [Pos.new(2, 0), Pos.new(2, 1), Pos.new(2, 2), Pos.new(0, 0), Pos.new(1, 0)]),
    Shape.new(:vbar, [Pos.new(0, 0), Pos.new(0, 1), Pos.new(0, 2), Pos.new(0, 3)]),
    Shape.new(:cube, [Pos.new(0, 0), Pos.new(0, 1), Pos.new(1, 0), Pos.new(1, 1)]),
  }

  class Pos
    getter x : Int32
    getter y : Int32

    def initialize(@x, @y)
    end

    def +(other : Pos)
      Pos.new(x + other.x, y + other.y)
    end
  end

  class Shape
    getter area : Array(Pos)
    getter name : Symbol

    def initialize(@name, @area)
    end

    def move(pos)
      Shape.new(name, area.map(&.+(pos)))
    end
  end

  TUNNEL_WIDENESS = 7
  FROM_TOP_SHIFT  = 4
  FROM_LEFT_SHIFT = 2

  DOWN  = Pos.new(0, -1)
  LEFT  = Pos.new(-1, 0)
  RIGHT = Pos.new(1, 0)

  class Game
    getter top : Int32

    @rocks : Set(Pos)
    @jets : Iterator({Int32, Pos})
    @patterns : Hash({Symbol, Int32, String}, {Int32, Int32})

    def initialize(jets : Array({Int32, Pos}))
      @rocks = Array.new(TUNNEL_WIDENESS) { |x| Pos.new(x, 0) }.to_set
      @top = 0
      @jets = jets.cycle
      @patterns = {} of {Symbol, Int32, String} => {Int32, Int32}
      @blocks = 0
    end

    def play(shape, cycle_detection = false, debug = false)
      current_shape = shape.move(Pos.new(FROM_LEFT_SHIFT, top + FROM_TOP_SHIFT))

      indexer, shifter = 🌬️

      if cycle_detection
        key = {shape.name, indexer, skyline}
        if @patterns.has_key?(key)
          return {@patterns[key], {@blocks, top}}
        end
        @patterns[key] = {@blocks, top}
      end

      while true
        # shift
        shifted_shape = current_shape.move(shifter)
        current_shape = shifted_shape if freespace?(shifted_shape)

        # down
        down_shape = current_shape.move(DOWN)

        if blocks?(down_shape)
          block(current_shape)
          return nil
        end

        current_shape = down_shape
        indexer, shifter = 🌬️
      end
    end

    def rock?(pos : Pos)
      @rocks.any? { |rock| rock.x == pos.x && rock.y == pos.y }
    end

    def freespace?(shape : Shape)
      shape.area.all? { |pos| !rock?(pos) && 0 <= pos.x < TUNNEL_WIDENESS }
    end

    def blocks?(shape : Shape)
      !freespace?(shape)
    end

    private def 🌬️
      @jets.next.as({Int32, Pos})
    end

    private def block(shape : Shape)
      shape.area.each { |pos| @rocks << pos }
      @top = @rocks.max_of(&.y)
      @blocks += 1
    end

    private def skyline
      (0...TUNNEL_WIDENESS).map { |x| rock?(Pos.new(x, top)) ? "#" : "." }.join("")
    end

    def debug(falling_shape)
      puts
      (top + FROM_TOP_SHIFT * 2).to(0).each do |y|
        print "|"
        (0...TUNNEL_WIDENESS).each do |x|
          pos = Pos.new(x, y)

          case
          when falling_shape && falling_shape.area.any? { |shape| shape.x == pos.x && shape.y == pos.y }
            print "@"
          when rock?(pos)
            print "#"
          else
            print "."
          end
        end
        print "|\n"
      end
      puts
    end
  end
end

puts "Part 1 : #{Day17.part1}"

puts "Part 2 : #{Day17.part2}"
