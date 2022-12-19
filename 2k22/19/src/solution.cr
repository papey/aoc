require "../../helpers/input"

module Day19
  def self.part1
    blueprints = parse(Input.new("../input/in"))

    blueprints.sum { |blueprint| blueprint.id * explore(blueprint, 24) }
  end

  def self.part2
  end

  def self.parse(input)
    input.lines(cleanup: true).each_with_object([] of Blueprint) do |line, acc|
      captures = line.scan(/\d+/).map(&.[0].to_i)
      acc << Blueprint.new(
        captures[0],
        {captures[1], 0, 0, 0},
        {captures[2], 0, 0, 0},
        {captures[3], captures[4], 0, 0},
        {captures[5], 0, captures[6], 0}
      )
    end
  end

  def self.explore(blueprint, minutes)
    queue = [{ {0, 0, 0, 0}, {1, 0, 0, 0} }]
    discovered = Set({Resources, Resources}).new

    collect = Proc(Resources, Resources, Resources).new do |resources, robots|
      {
        resources[Kind::Ore] + robots[Kind::Ore],
        resources[Kind::Clay] + robots[Kind::Clay],
        resources[Kind::Obsidian] + robots[Kind::Obsidian],
        resources[Kind::Geode] + robots[Kind::Geode],
      }
    end

    minutes.times do |min|
      next_queue = [] of {Resources, Resources}

      queue.each do |resources, robots|
        next if discovered.includes?({resources, robots})

        discovered << {resources, robots}

        if blueprint.buildable?(Kind::Geode, resources)
          next_queue << {
            collect.call(blueprint.build(Kind::Geode, resources), robots),
            {robots[Kind::Ore],
             robots[Kind::Clay],
             robots[Kind::Obsidian],
             robots[Kind::Geode] + 1},
          }
          next
        end

        if blueprint.needs?(Kind::Obsidian, robots) && blueprint.buildable?(Kind::Obsidian, resources)
          next_queue << {
            collect.call(blueprint.build(Kind::Obsidian, resources), robots),
            {robots[Kind::Ore],
             robots[Kind::Clay],
             robots[Kind::Obsidian] + 1,
             robots[Kind::Geode]},
          }
        end

        if blueprint.needs?(Kind::Clay, robots) && blueprint.buildable?(Kind::Clay, resources)
          next_queue << {
            collect.call(blueprint.build(Kind::Clay, resources), robots),
            {robots[Kind::Ore],
             robots[Kind::Clay] + 1,
             robots[Kind::Obsidian],
             robots[Kind::Geode]},
          }
        end

        if blueprint.needs?(Kind::Ore, robots) && blueprint.buildable?(Kind::Ore, resources)
          next_queue << {
            collect.call(blueprint.build(Kind::Ore, resources), robots),
            {robots[Kind::Ore] + 1,
             robots[Kind::Clay],
             robots[Kind::Obsidian],
             robots[Kind::Geode]},
          }
        end

        next_queue << {
          collect.call(resources, robots),
          robots,
        }
      end

      queue = next_queue
    end

    queue.max_of { |(resources, _robots)| resources[Kind::Geode] }
  end

  enum Kind
    Ore      = 0
    Clay     = 1
    Obsidian = 2
    Geode    = 3
  end

  alias Resources = Tuple(Int32, Int32, Int32, Int32)

  class Blueprint
    getter costs : {Resources, Resources, Resources, Resources}
    getter id : Int32

    @id : Int32
    @costs_by_kind : Resources

    def initialize(@id, ore_robot_cost, clay_robot_cost, obsidian_robot_cost, geode_robot_cost)
      @costs = {ore_robot_cost, clay_robot_cost, obsidian_robot_cost, geode_robot_cost}
      @costs_by_kind = @costs.reduce({0, 0, 0, 0}) do |(ore, clay, obsidian, geode), cost|
        {ore + cost[Kind::Ore], clay + cost[Kind::Clay], obsidian + cost[Kind::Obsidian], 0}
      end
    end

    def buildable?(kind, resources)
      @costs[kind.to_i].zip(resources).all? { |c, r| c <= r }
    end

    def build(kind, resources)
      index = kind.to_i

      {
        resources[Kind::Ore] - @costs[index][Kind::Ore],
        resources[Kind::Clay] - @costs[index][Kind::Clay],
        resources[Kind::Obsidian] - @costs[index][Kind::Obsidian],
        resources[Kind::Geode],
      }
    end

    def needs?(kind, robots)
      @costs_by_kind[kind.to_i] > robots[kind.to_i]
    end
  end
end

puts "Part 1 : #{Day19.part1}"

puts "Part 2 : #{Day19.part2}"
