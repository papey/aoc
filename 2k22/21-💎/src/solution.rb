# frozen_string_literal: true

module Day21
  def self.part1
    expressions = parse

    compute(expressions, :root)
  end

  def self.part2
  end

  def self.compute(vars, monkey)
    case vars[monkey]
    in [:value, v]
      v
    in [:expression, exp]
      a, method, b = exp

      compute(vars, a).method(method).call(compute(vars, b))
    end
  end

  def self.parse
    File
      .readlines("../input/in")
      .map(&:strip)
      .each_with_object({}) do |line, acc|
        name, expression = line.split(": ")
        if /\d+/.match(expression)
          acc[name.to_sym] = [:value, expression.to_i]
        else
          acc[name.to_sym] = [:expression, expression.split.map(&:to_sym)]
        end
      end
  end
end

puts "Part 1: #{Day21.part1}"

puts "Part 2: #{Day21.part2}"
