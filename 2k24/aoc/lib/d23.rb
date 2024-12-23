#!/usr/bin/env ruby
# frozen_string_literal: true

require "set"

def parse
  File.readlines("../inputs/d23.txt").map(&:chomp).map { |l| l.split("-") }
end

def p1
  conns = parse.each_with_object(Hash.new { |h, k| h[k] = [] }) do |(a, b), h|
    h[a] << b
    h[b] << a
  end

  triplets(conns).count { |computers| computers.any? { |c| c.start_with?("t") } }
end

def p2
  conns = parse.each_with_object(Hash.new { |h, k| h[k] = [] }) do |(a, b), h|
    h[a] << b
    h[b] << a
  end

  bron_kerbosch([], conns.keys, [], conns).max_by(&:size).sort.join(",")
end

def triplets(conns)
  conns.each_with_object([Set.new, Set.new]) do |(origin, connected), (triplets, visited)|
    connected.each do |n1|
      next if visited.include?([origin, n1].sort)
      visited << [origin, n1].sort
      conns[n1].each do |n2|

        next if [origin, n1, n2].uniq.size < 3 || !connected.include?(n2)

        triplets << [origin, n1, n2].sort
      end
    end
  end.first
end

def bron_kerbosch(r, p, x, conns, cliques = [])
  if p.empty? && x.empty?
    cliques << r
  else
    p.each do |vertex|
      bron_kerbosch(
        r + [vertex],
        p & conns[vertex],
        x & conns[vertex],
        conns,
        cliques
      )
      p -= [vertex]
      x += [vertex]
    end
  end

  cliques
end

puts "p1: #{p1.inspect}"

puts "p2: #{p2.inspect}"
