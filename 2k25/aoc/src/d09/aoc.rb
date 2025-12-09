# frozen_string_literal: true

class Box
  attr_reader :x_min, :x_max, :y_min, :y_max

  def initialize(corner_a, corner_b)
    ax, ay = corner_a
    bx, by = corner_b
    @x_min, @x_max = [ax, bx].minmax
    @y_min, @y_max = [ay, by].minmax
  end

  def area
    @area ||= (1 + (x_max - x_min)) * (1 + (y_max - y_min))
  end

  # i am good at ascii art 😂
  # check this out
  #  pymin----<--------pymax
  #
  #
  #           x################x
  #  pymin----<--------pymax   #
  #           #       pymin---->--------pymax
  #           #                #    pymin---->--------pymax
  #           x################x
  #
  #
  def cut_by?(p1, p2)
    px1, py1 = p1
    px2, py2 = p2

    # vertical edge, horizontal cut
    if px1 == px2
      return(
        strictly_between?(px1, x_min, x_max) &&
          overlaps?(py1, py2, y_min, y_max)
      )
    end

    # horizontal edge, vertical cut
    if py1 == py2
      return(
        strictly_between?(py1, y_min, y_max) &&
          overlaps?(px1, px2, x_min, x_max)
      )
    end

    false
  end

  private

  def overlaps?(a, b, c, d)
    [a, b].max > c && [a, b].min < d
  end

  def strictly_between?(val, min, max)
    val > min && val < max
  end
end

coords =
  File
  .readlines('inputs/d09.txt', chomp: true)
  .map { _1.split(',') }
  .flat_map { [_1.map(&:to_i)] }

p1 = coords.combination(2).map { Box.new(_1, _2) }.map(&:area).max
puts "p1: #{p1}"

polygon_edges = coords.each_cons(2).to_a + [[coords.last, coords.first]]

p2 =
  coords
  .combination(2)
  .map { |a, b| Box.new(a, b) }
  .sort_by { |b| -b.area }
  .find { |box| polygon_edges.none? { |p1, p2| box.cut_by?(p1, p2) } }
  .area

puts "p2: #{p2}"
