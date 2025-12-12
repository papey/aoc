# frozen_string_literal: true

raw_shapes, raw_regions =
  File
  .read('inputs/d12.txt')
  .split("\n\n")
  .group_by { |part| part.start_with?(/\d+:/) }
  .then { [_1[true], _1[false]] }

shapes =
  raw_shapes.map do |raw_shape|
    id, data = raw_shape.split(":\n")
    shape = data.lines.map(&:chomp)
    { id: id.to_i, shape: shape, items: shape.join('').count('#') }
  end

regions =
  raw_regions
  .filter { _1 != '' }
  .first
  .split("\n")
  .map do |raw_region|
    s, n = raw_region.split(':')
    needs = n.split(' ').map { _1.strip.to_i }
    a, b = s.split('x').map { _1.strip.to_i }
    { dimension: a * b, needs: needs }
  end

p1 =
  regions
  .filter do |region|
    needs_at_least =
      region[:needs].each_with_index.sum { |need, index| shapes[index][:items] * need }

    region[:dimension] >= needs_at_least
  end
    .length

puts "p1: #{p1}"
