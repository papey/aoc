# frozen_string_literal: true

def distance(a, b)
  (0..2).sum { (a[_1] - b[_1])**2 }.then { Math.sqrt(_1) }
end

class UnionFinder
  def initialize(elements)
    @parents = {}
    elements.each { |e| @parents[e] = e }
  end

  def find(e)
    @parents[e] = find(@parents[e]) if @parents[e] != e

    @parents[e]
  end

  def union(a, b)
    root_a = find(a)
    root_b = find(b)
    @parents[root_a] = root_b if root_a != root_b

    root_b
  end
end

coords =
  File
  .readlines('inputs/d08.txt', chomp: true)
  .map { _1.split(',') }
  .each_with_index
  .map { [_2, _1.map(&:to_i)] }

distances =
  coords
  .combination(2)
  .map { |a, b| { d: distance(a[1], b[1]), a: a[0], b: b[0] } }
  .sort { _1[:d] <=> _2[:d] }

uf = UnionFinder.new(coords.map { _1[0] })

ITER = 1000
distances[0...ITER].each { |elem| uf.union(elem[:a], elem[:b]) }

groups =
  (0..coords.size).each_with_object(Hash.new(0)) { |i, h| h[uf.find(i)] += 1 }

p1 = groups.values.sort_by(&:-@).take(3).reduce(:*)
puts "p1: #{p1}"

uf = UnionFinder.new(coords.map { _1[0] })

d =
  distances.find do |elem|
    uf.union(elem[:a], elem[:b])
    (0...coords.size).all? { uf.find(_1) == uf.find(0) }
  end

p2 = %i[a b].map { coords[d[_1]][1][0] }.reduce(:*)
puts "p2: #{p2}"
