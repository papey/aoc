#!/usr/bin/env ruby
# frozen_string_literal: true

def p1
  raw_disk = parse
  mem = to_memory(raw_disk)

  current = 0
  last = mem.length - 1

  while current < last
    if mem[current]
      current += 1
      next
    end

    mem[current], mem[last] = mem[last], mem[current]
    current += 1
    last = mem[..last].rindex { |v| !v.nil? }
  end

  hash(mem)
end

def p2
  raw_disk = parse
  mem = to_memory(raw_disk)
  bound, free = analyze(mem)

  defrag = {}

  bound.keys.reverse.each do |key|
    state = bound[key]
    required_space = state[:len]

    index, space =
      free
        .select { |k, v| k < state[:index] && v >= required_space }
        .min_by { |k, _v| k }

    # no defrag possible
    if index.nil?
      defrag[key] = bound[key]
      next
    end

    # defrag
    defrag[key] = { index: index, len: required_space }

    # update and track new free space
    free[bound[key][:index]] = required_space

    free[index + required_space] = space - required_space if space !=
      required_space
    free.delete(index)
  end

  mem = []

  defrag
    .sort_by { |_k, v| v[:index] }
    .each do |k, v|
      mem += [nil] * (v[:index] - mem.length) unless v[:index] == mem.length
      mem += [k] * v[:len]
    end

  hash(mem)
end

def analyze(mem)
  cursor = 0
  bound = {}
  free = {}

  while cursor < mem.length
    start = cursor
    id = mem[cursor]
    l = 0

    while mem[cursor] == id
      cursor += 1
      l += 1
    end

    if id.nil?
      free[start] = l
    else
      bound[id] = { index: start, len: l }
    end
  end

  [bound, free]
end

def hash(mem)
  mem.each_with_index.sum { |id, index| id.nil? ? 0 : id * index }
end

def to_memory(raw_disk)
  raw_disk
    .each_char
    .map(&:to_i)
    .each_with_index
    .reduce([[], 0]) do |(acc, id), (v, i)|
      i.even? ? [acc + [id] * v, id + 1] : [acc + [nil] * v, id]
    end
    .first
end

def parse
  File.open("../inputs/d09.txt").readlines.map(&:chomp).first
end

puts ["p1", p1].inspect

puts ["p2", p2].inspect
