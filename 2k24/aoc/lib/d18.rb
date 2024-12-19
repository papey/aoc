#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'

def parse
  File.readlines('../inputs/d18.txt').map(&:chomp).map { |line| line.split(',') }.map { |elem| elem.map(&:to_i) }
end

MAXY = MAXX = 71
BYTES = 1024

def p1
  corrupted = parse

  path(corrupted, BYTES)
end

def p2
  corrupted = parse

  u = 1024
  l = corrupted.length

  while u < l
    m = (u + l) / 2
    if path(corrupted, m)
      u = m + 1
    else
      l = m
    end
  end

  corrupted[l - 1]
end

def grid(corrupted, l)
  grid = Array.new(MAXY) { Array.new(MAXX, '.') }

  corrupted[0, l].each do |x, y|
    grid[y][x] = '#'
  end

  grid
end

def path(corrupted, l)
  grid = grid(corrupted, l)

  exit = [MAXY - 1, MAXX - 1]
  queue = [[[0, 0], 0]]
  seen = Set.new([[0, 0]])

  while queue.length.positive?
    (y, x), steps = queue.shift

    return steps if exit == [y, x]

    [[1, 0], [0, 1], [-1, 0], [0, -1]].each do |dy, dx|
      ny = y + dy
      nx = x + dx

      in_bound = nx >= 0 && nx < MAXX && ny >= 0 && ny < MAXY
      if in_bound && grid[ny][nx] == '.' && !seen.include?([ny, nx])
        seen.add([ny, nx])
        queue.push([[ny, nx], steps + 1])
      end
    end
  end
end

puts "p1: #{p1.inspect}"

puts "p2: #{p2.inspect}"
