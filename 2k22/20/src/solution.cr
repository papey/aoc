require "../../helpers/input"

module Day20
  def self.part1
    data = Input.new("../input/in").lines(cleanup: true).map_with_index { |v, i| [v.to_i, i] }

    self.mix!(data, data.size)

    sum!(data)
  end

  def self.part2
    key = 811589153
    data = Input.new("../input/in").lines(cleanup: true).map_with_index { |v, i| [v.to_i64 * key, i.to_i64] }

    10.times do
      self.mix!(data, data.size)
    end

    sum!(data)
  end

  def self.mix!(data, size)
    size.times do |round|
      index = data.index! { |(_v, i)| i == round }
      shift, _i = replace = data.delete_at(index)
      data.insert((shift + index) % (size - 1), replace)
    end
  end

  def self.sum!(data)
    start = data.index! { |(v, _i)| v == 0 }
    {1000, 2000, 3000}.sum { |i| data[(i + start) % data.size].first }
  end
end

puts "Part 1 : #{Day20.part1}"

puts "Part 2 : #{Day20.part2}"
