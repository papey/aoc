require "../../helpers/input"

module Day02
  def self.part1
    input = Input.new("../input/in")

    input.split(cleanup: true).sum { |line| Game.from_play_input(line).score }
  end

  def self.part2
    input = Input.new("../input/in")

    input.split(cleanup: true).sum { |line| Game.from_outcome_input(line).score }
  end
end

class Game
  enum Shape
    Rock     = 1
    Paper    = 2
    Scissors = 3
  end

  enum Outcome
    Loose = 0
    Win   = 6
    Draw  = 3
  end

  @opponent : Shape
  @play : Shape

  WINS = {Shape::Rock => Shape::Scissors, Shape::Scissors => Shape::Paper, Shape::Paper => Shape::Rock}

  def self.from_play_input(line : String)
    opponent_raw_shape, player_raw_shape = line.split

    Game.new(opponent_shape(opponent_raw_shape), player_shape(player_raw_shape))
  end

  def self.from_outcome_input(line : String)
    raw_shape, raw_outcome = line.split
    opponent = opponent_shape(raw_shape)

    outcome = case raw_outcome.chars.first
              when 'X'
                Outcome::Loose
              when 'Y'
                Outcome::Draw
              when 'Z'
                Outcome::Win
              else
                raise "Error input value #{raw_outcome} is invalid"
              end

    Game.new(opponent, should_play(opponent, outcome))
  end

  private def self.opponent_shape(raw_shape)
    Shape.new(raw_shape.chars.first - 'A' + 1)
  end

  private def self.player_shape(raw_shape)
    Shape.new(raw_shape.chars.first - 'X' + 1)
  end

  private def self.should_play(opponent : Shape, outcome : Outcome) : Shape
    case outcome
    when Outcome::Loose
      WINS[opponent]
    when Outcome::Draw
      opponent
    when Outcome::Win
      WINS.invert[opponent]
    end.not_nil!
  end

  def initialize(@opponent, @play)
  end

  def score
    @play.value + outcome.value
  end

  private def outcome
    if draw?
      Outcome::Draw
    elsif win?
      Outcome::Win
    else
      Outcome::Loose
    end
  end

  private def win?
    WINS[@play] == @opponent
  end

  private def draw?
    @play == @opponent
  end
end

puts "Part 1 : #{Day02.part1}"

puts "Part 2 : #{Day02.part2}"
