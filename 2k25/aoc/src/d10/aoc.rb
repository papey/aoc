# frozen_string_literal: true

machines =
  File
  .readlines('./inputs/d10.txt')
  .map do |line|
    parts = line.strip.split(' ')

    raw_indicator = parts.shift.then { |s| s[1...s.length - 1] }
    target_mask = 0
    raw_indicator.chars.each_with_index do |char, idx|
      target_mask |= (1 << idx) if char == '#'
    end

    joltage = parts.pop
    button_masks =
      parts
      .map { |b| b.delete_suffix(')').delete_prefix('(') }
      .map do |b|
        indices = b.split(',').map(&:to_i)
        indices.reduce(0) { |mask, idx| mask | (1 << idx) }
      end

    { target: target_mask, joltage: joltage, buttons: button_masks }
  end

module Configurator
  module_function

  def configure(machine)
    target = machine[:target]
    buttons = machine[:buttons]

    visited = { 0 => 0 }
    queue = [0]

    while queue.any?
      state = queue.shift
      cost = visited[state]

      return cost if state == target

      buttons.each do |mask|
        next_state = state ^ mask

        unless visited.key?(next_state)
          visited[next_state] = cost + 1
          queue.push(next_state)
        end
      end
    end
  end
end

p1 = machines.map { |m| Configurator.configure(m) }.sum
puts "p1: #{p1}"
