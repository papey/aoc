#!/usr/bin/env ruby
# frozen_string_literal: true

def parse
  maze =
    File
      .readlines("../inputs/d16.txt")
      .map(&:chomp)
      .each_with_index
      .each_with_object(Hash.new("#")) do |(line, index), acc|
        line.chars.each_with_index { |char, i| acc[[index, i]] = char }
      end

  start = maze.find { |_, v| v == "S" }
  exit = maze.find { |_, v| v == "E" }

  [start.first, exit.first, maze]
end

def solve(start, exit, maze)
  seats = Set.new
  seen = Hash.new(Float::INFINITY)
  path = Set.new(start)
  queue = [[start, [0, 1], 0, path]]

  best_score = Float::INFINITY

  until queue.empty?
    pos, dir, score, path = queue.shift

    next if score > seen[[pos, dir]] || score > best_score

    seen[[pos, dir]] = score

    if pos == exit
      if score < best_score
        best_score = score
        seats = Set.new(path)
      end

      seats.merge(path) if score == best_score

      next
    end

    dy, dx = dir
    y, x = pos
    if maze[[y + dy, x + dx]] != "#"
      p = path.clone
      p.add([y + dy, x + dx])
      queue.push([[y + dy, x + dx], dir, score + 1, p])
    end

    queue.push([[y, x], [dx, dy], score + 1000, path.clone])
    queue.push([[y, x], [-dx, -dy], score + 1000, path.clone])

    queue.sort_by! { |_, _, s, _| s }
  end

  [best_score, seats.size - 1]
end

start, exit, maze = parse

p1, p2 = solve(start, exit, maze)

puts "p1: #{p1.inspect}"
puts "p2: #{p2.inspect}"
