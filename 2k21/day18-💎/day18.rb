class Value
  attr_accessor :value

  alias magnitude value

  def initialize(value = 0)
    self.value = value
  end

  def to_s
    value.to_s
  end

  def +(other)
    self.value += other.value
  end

  alias addr :+
  alias addl :+

  def explodes(_)
    nil
  end

  def split
    return nil if value < 10

    h = value / 2
    Pair.new(Value.new(h), Value.new(value - h))
  end
end

class Pair
  attr_accessor :left, :right

  def self.from_string(input)
    number = Integer(input, exception: false)
    return Value.new(number) if number

    inner = input[1..-2]
    level = 0
    comma = inner.chars.find_index do |c|
      next true if level.zero? && c == ','

      level += 1 if c == '['
      level -= 1 if c == ']'

      false
    end

    new(from_string(inner[0...comma]), from_string(inner[comma + 1..-1]))
  end

  def initialize(left, right)
    self.left = left
    self.right = right
  end

  def magnitude
    3 * left.magnitude + 2 * right.magnitude
  end

  def +(other)
    p = Pair.new(self, other)
    p.reduce
  end

  def to_s
    "[#{left},#{right}]"
  end

  def reduce
    while explodes(0) || split
    end

    self
  end

  def split
    l = left.split
    if l
      self.left = l
      return self
    end

    r = right.split
    return nil unless r

    self.right = r
    self
  end

  def explodes(level)
    return self if level == 4

    res = left.explodes(level + 1)

    if res
      self.left = Value.new if level == 3
      right.addl(res.right)

      return Pair.new(res.left, Value.new(0))
    end

    res = right.explodes(level + 1)

    if res
      self.right = Value.new if level == 3
      left.addr(res.left)

      return Pair.new(Value.new, res.right)
    end

    nil
  end

  def addr(value)
    right.addr(value)
  end

  def addl(value)
    left.addl(value)
  end
end

def part1(lines)
  numbers = lines.map { |line| Pair.from_string(line) }
  init = numbers.shift
  numbers.reduce(init) { |acc, n| acc + n }.magnitude
end

def part2(lines)
  (0...lines.length)
    .to_a.combination(2)
    .map { |a, b| (Pair.from_string(lines[a]) + Pair.from_string(lines[b])).magnitude }
    .max
end

file = File.open('inputs/input.txt')
lines = file.readlines.filter { |line| !line.empty? }.map(&:strip)

puts "Part 1: #{part1(lines)} "

puts "Part 2: #{part2(lines)}"
