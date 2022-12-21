# frozen_string_literal: true

module Day21
  def self.part1
    expressions = parse

    compute(expressions, :root)
  end

  def self.part2
    expressions = parse

    a = build_expression(expressions, expressions[:root][0])
    b = build_expression(expressions, expressions[:root][2])

    a.is_a?(Integer) ? solve(b, a) : solve(a, b)
  end

  def self.compute(expressions, monkey)
    case expressions[monkey]
    in [a, method, b]
      compute(expressions, a).method(method).call(compute(expressions, b))
    in value
      value
    end
  end

  def self.build_expression(expressions, key)
    return key if key == :humn

    case expressions[key]
    in [a, method, b]
      va = build_expression(expressions, a)
      vb = build_expression(expressions, b)
      if va.is_a?(Integer) && vb.is_a?(Integer)
        va.method(method).call(vb)
      else
        [va, method, vb]
      end
    in value
      value
    end
  end

  def self.solve(expression, value)
    return value if expression == :humn

    a, method, b = expression

    case method
    when :+
      a.is_a?(Integer) ? solve(b, value - a) : solve(a, value - b)
    when :-
      a.is_a?(Integer) ? solve(b, a - value) : solve(a, b + value)
    when :*
      a.is_a?(Integer) ? solve(b, value / a) : solve(a, value / b)
    when :/
      a.is_a?(Integer) ? solve(b, a / value) : solve(a, b * value)
    end
  end

  def self.parse
    File
      .readlines("../input/in")
      .map(&:strip)
      .each_with_object({}) do |line, acc|
        name, expression = line.split(": ")
        if /\d+/.match(expression)
          acc[name.to_sym] = expression.to_i
        else
          acc[name.to_sym] = expression.split.map(&:to_sym)
        end
      end
  end
end

puts "Part 1: #{Day21.part1}"

puts "Part 2: #{Day21.part2}"
