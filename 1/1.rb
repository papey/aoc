#!/usr/bin/env ruby

# AOC class
class AOC

  # init from in file
  def initialize(filename = "./input/in")
    # Modules is an array
    @modules = Array.new
    # Loop over lines
    File.open(filename).each do |line|
      @modules << line.to_i
    end
  end

  # calculate all fuel for all modules
  def all_fuel(full = false)
    total = @modules.reduce(0) do |acc, element|
    acc + compute_fuel_full(element, full)
    end
    total
  end

  # compute fuel for one module
  def compute_fuel(element)
    (element/3).floor - 2
  end

  # compute needed fuel, + fuel for the fuel !
  def compute_fuel_full(fuel, full = false)
    # final condition
    return 0 if fuel < 7
    # short mode
    needed = compute_fuel(fuel)
    # full mode
    needed += compute_fuel_full(needed, full) if full
    # return final value
    needed
  end

end


# Main file
if __FILE__ == $0
  # init
  aoc = AOC.new

  # short version
  fuel = aoc.all_fuel(false)

  print "Fuel (short): #{fuel}\n"

  # full version
  fuel = aoc.all_fuel(true)

  print "Fuel (full): #{fuel}\n"
end
