require "../../helpers/input"

module Day17
  TUNNEL_WIDENESS = 7
  FROM_TOP_SHIFT  = 4
  FROM_LEFT_SHIFT = 2

  DOWN = Pos.new(0, -1)

  def self.part1
    jets = Input.new("../input/in").lines.first.split("").map { |move| move == "<" ? Pos.new(-1, 0) : Pos.new(1, 0) }

    game = Game.new(jets)

    SHAPES.cycle.first(2022).each { |shape| game.play(shape) }

    game.top
  end

  def self.part2
  end

  SHAPES = {
    [Pos.new(0, 0), Pos.new(1, 0), Pos.new(2, 0), Pos.new(3, 0)],
    [Pos.new(0, 1), Pos.new(1, 0), Pos.new(1, 1), Pos.new(1, 2), Pos.new(2, 1)],
    [Pos.new(2, 0), Pos.new(2, 1), Pos.new(2, 2), Pos.new(0, 0), Pos.new(1, 0)],
    [Pos.new(0, 0), Pos.new(0, 1), Pos.new(0, 2), Pos.new(0, 3)],
    [Pos.new(0, 0), Pos.new(0, 1), Pos.new(1, 0), Pos.new(1, 1)],
  }

  alias Shape = Array(Pos)

  class Pos
    getter x : Int32
    getter y : Int32

    def initialize(@x, @y)
    end

    def +(other : Pos)
      Pos.new(x + other.x, y + other.y)
    end
  end

  class Game
    getter top : Int32

    @rocks : Set(Pos)
    @jets : Iterator(Pos)

    def initialize(jets : Shape)
      @rocks = Array.new(TUNNEL_WIDENESS) { |x| Pos.new(x, 0) }.to_set
      @top = 0
      @jets = jets.cycle
    end

    def play(shape)
      current_shape = shape.map(&.+(Pos.new(FROM_LEFT_SHIFT, top + FROM_TOP_SHIFT)))

      while true
        # shift
        shifter = 🌬️
        shifted_shape = current_shape.map(&.+(shifter))
        current_shape = shifted_shape if freespace?(shifted_shape)

        # down
        down_shape = current_shape.map(&.+(DOWN))

        if blocks?(down_shape)
          block(current_shape)
          break
        end

        current_shape = down_shape
      end
    end

    def rock?(pos : Pos)
      @rocks.any? { |rock| rock.x == pos.x && rock.y == pos.y }
    end

    def 🌬️
      @jets.next.as(Pos)
    end

    def freespace?(shape : Shape)
      shape.all? { |pos| !rock?(pos) && 0 <= pos.x < TUNNEL_WIDENESS }
    end

    def blocks?(shape : Shape)
      !freespace?(shape)
    end

    def block(shape : Shape)
      shape.each { |pos| @rocks << pos }
      @top = @rocks.max_of(&.y)
    end

    def print(falling_shape)
      puts
      (top + FROM_TOP_SHIFT * 2).to(0).each do |y|
        print "|"
        (0...TUNNEL_WIDENESS).each do |x|
          pos = Pos.new(x, y)

          case
          when falling_shape && falling_shape.any? { |shape| shape.x == pos.x && shape.y == pos.y }
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
