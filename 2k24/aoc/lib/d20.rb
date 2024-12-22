#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'

def parse
  File.readlines('../inputs/d20.txt').map(&:chomp).map(&:chars)
end

def p1
  grid = parse

  start, exit = interests(grid)

  _cost, path = path(grid, start, exit)

  cheat(path, 2)
end

def p2
  grid = parse

  start, exit = interests(grid)

  _cost, path = path(grid, start, exit)

  cheat(path, 20)
end

VALUEABLE_CHEAT = 100

def cheat(path, cheat_time)
  path.each_with_index.reduce(0) do |acc, ((cy, cx), starts_cheat_at)|
    path[starts_cheat_at + 1..].each.with_index(1).reduce(acc) do |inner_acc, ((ty, tx), savings)|
      dx = (cx - tx).abs
      dy = (cy - ty).abs
      delta = dx + dy

      if delta <= cheat_time && savings - delta >= VALUEABLE_CHEAT
        inner_acc + 1
      else
        inner_acc
      end
    end
  end
end

def interests(grid)
  start = nil
  exit = nil

  grid.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      start = [y, x] if cell == 'S'
      exit = [y, x] if cell == 'E'
    end
  end

  [start, exit]
end

def path(grid, start, exit)
  queue = [[start, 0, [start]]]
  seen = Set.new([start])

  until queue.empty?
    (y, x), steps, path = queue.shift

    return [steps, path] if exit == [y, x]

    [[1, 0], [0, 1], [-1, 0], [0, -1]].each do |dy, dx|
      ny = y + dy
      nx = x + dx

      in_bound = grid[ny] && !grid[ny][nx].nil?
      if in_bound && grid[ny][nx] != '#' && !seen.include?([ny, nx])
        seen.add([ny, nx])
        queue.push([[ny, nx], steps + 1, path.clone << [ny, nx]])
      end
    end
  end
end

puts "p1: #{p1.inspect}"

puts "p2: #{p2.inspect}"
