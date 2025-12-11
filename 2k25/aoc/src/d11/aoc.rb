# frozen_string_literal: true

graph =
  File
  .readlines('inputs/d11.txt', chomp: true)
  .each_with_object({}) do |line, g|
    from, to = line.split(':')
    g[from] = to.split(' ').map(&:strip)
  end

def find_all(graph, start, goal)
  memo = {}

  dfs =
    lambda do |current_node|
      return memo[current_node] if memo.key?(current_node)

      if current_node == goal
        memo[current_node] = 1
        return 1
      end

      memo[current_node] = graph
                           .fetch(current_node, [])
                           .reduce(0) { |sum, neighbor| sum + dfs.call(neighbor) }
    end

  dfs.call(start)
end

puts "p1: #{find_all(graph, 'you', 'out')}"

p2 =
  [
    [%w[svr fft], %w[fft dac], %w[dac out]],
    [%w[svr dac], %w[dac fft], %w[fft out]]
  ].map { |sub| sub.map { |from, to| find_all(graph, from, to) }.reduce(&:*) }
  .reduce(&:+)

puts "p2: #{p2}"
