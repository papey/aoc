#!/usr/bin/env ruby
# frozen_string_literal: true

require "set"

def parse
  File.readlines("../inputs/d21.txt").map(&:chomp)
end

KEYPAD = [%w[7 8 9], %w[4 5 6], %w[1 2 3], [" ", "0", "A"]]
DPAD = [[" ", "^", "A"], %w[< v >]]
GRIDS = { npad: KEYPAD, dpad: DPAD }
DIRS = { [1, 0] => "v", [-1, 0] => "^", [0, 1] => ">", [0, -1] => "<" }

def paths(origin, target, name)
  with_caching(name, [origin, target]) do
    grid = GRIDS[name]
    oy, ox = poi(grid, origin)
    ty, tx = poi(grid, target)

    seen = Set.new([[oy, ox]])
    queue = [[oy, ox, []]]
    paths = []

    min = Float::INFINITY

    until queue.empty?
      y, x, path = queue.shift
      distance = path.length

      next if distance > min

      seen.add([y, x])

      if [y, x] == [ty, tx]
        min = distance
        paths << "#{path.join("")}A"
        next
      end

      DIRS.each do |(dy, dx), v|
        ny, nx = y + dy, x + dx
        if grid[ny] && grid[ny][nx] && grid[ny][nx] != " " &&
             !seen.include?([ny, nx])
          queue.append([ny, nx, path + [v]])
        end
      end
    end

    paths
  end
end

def dpad_sequence(code, n)
  with_caching(:sequences, [code, n]) do
    return code.length if n == 0

    res, _ =
      code
        .each_char
        .reduce([0, "A"]) do |(seq_len, pointing), c|
          paths = paths(pointing, c, :dpad)
          subpath_len = paths.map { |p| dpad_sequence(p, n - 1) }.min
          [seq_len + subpath_len, c]
        end

    res
  end
end

def sequence(code, n)
  code
    .each_char
    .reduce([0, "A"]) do |(seq_len, pointing), c|
      paths = paths(pointing, c, :npad)
      subpath_len = paths.map { |p| dpad_sequence(p, n) }.min
      [seq_len + subpath_len, c]
    end
    .first
end

def poi(grid, poi)
  x = nil
  y = nil

  grid.each_with_index do |row, i|
    if row.include?(poi)
      x = row.index(poi)
      y = i
      break
    end
  end

  [y, x]
end

def with_caching(cache_name, cache_key, &block)
  @cacache ||= { npad: {}, dpad: {}, sequences: {} }

  cache = @cacache[cache_name]

  return cache[cache_key] if cache.key?(cache_key)

  cache[cache_key] = block.call
end

def p1
  codes = parse

  codes.sum { |code| code.gsub("A", "").to_i * sequence(code, 2) }
end

def p2
  codes = parse

  codes.sum { |code| code.gsub("A", "").to_i * sequence(code, 25) }
end

puts "p1: #{p1.inspect}"

puts "p2: #{p2.inspect}"
