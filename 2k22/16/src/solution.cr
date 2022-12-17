require "../../helpers/input"

module Day16
  def self.part1
    valves = parse(Input.new("../input/in"))

    distances = distances(valves)

    active_valves = valves.reject { |valve| valve.flow == 0 }

    paths("AA", active_valves, 30, distances, 0, "AA").max[0]
  end

  def self.part2
    valves = parse(Input.new("../input/in"))

    distances = distances(valves)

    active_valves = valves.reject { |valve| valve.flow == 0 }

    path_candidates = paths("AA", active_valves, 26, distances, 0, "AA")
      .map { |(pressure, path)| {pressure, path.split("-").reject { |room| room == STARTING_ROOM }.to_set} }

    # takes forever but meh, it works
    🏃‍♂️🐘(path_candidates)
  end

  STARTING_ROOM = "AA"

  def self.distances(valves)
    distances = valves.each_with_object(Hash(String, Hash(String, Int32)).new(initial_capacity: valves.size)) do |src, accumulator|
      accumulator[src.name] = Hash(String, Int32).new(Int32::MAX)
      accumulator[src.name][src.name] = 0

      src.connections.each do |dst|
        accumulator[src.name][dst] = 1
      end
    end

    valves.each do |v1|
      valves.each do |v2|
        valves.each do |v3|
          next if {distances[v2.name][v1.name], distances[v1.name][v3.name]}.any? { |v| v == Int32::MAX }

          distances[v2.name][v3.name] = {distances[v2.name][v3.name],
                                         distances[v2.name][v1.name] + distances[v1.name][v3.name]}.min
        end
      end
    end

    distances
  end

  def self.paths(current_valve, valves_to_explore, time, distances, pressure, path)
    _paths = [{pressure, path}]

    valves_to_explore.each do |target_valve|
      distance = distances[current_valve][target_valve.name]

      next if distance >= time

      remaining_valves = valves_to_explore.reject { |v| target_valve.name == v.name }
      remaining_time = time - distance - 1
      added_pressure = target_valve.flow * remaining_time

      _paths += paths(target_valve.name, remaining_valves, remaining_time, distances, added_pressure + pressure, "#{path}-#{target_valve.name}")
    end

    return _paths
  end

  def self.🏃‍♂️🐘(path_candidates)
    max_pressure = Int32::MIN

    (0...path_candidates.size).each do |p1|
      (p1 + 1...path_candidates.size).each do |p2|
        next if p1 > p2

        next if path_candidates[p1][1].intersects?(path_candidates[p2][1])

        max_pressure = {max_pressure, path_candidates[p1][0] + path_candidates[p2][0]}.max
      end
    end

    max_pressure
  end

  INPUT_REGEX = /Valve ([A-Z]+) has flow rate=(\d+); tunnel[s]? lead[s]? to valve[s]? ([A-Z, ]+)/

  private def self.parse(input)
    input.raw.scan(INPUT_REGEX).each_with_object([] of Valve) do |match, accumulator|
      raw_name, raw_flow, raw_connections = match.captures.compact
      accumulator << Valve.new(raw_name, raw_flow.to_i, raw_connections.split(",").map(&.strip))
    end
  end

  class Valve
    getter name : String
    getter flow : Int32
    getter connections : Array(String)

    def initialize(@name, @flow, @connections)
    end
  end
end

puts "Part 1 : #{Day16.part1}"

puts "Part 2 : #{Day16.part2}"
