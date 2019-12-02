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

  # compute needed fuel will calculate the amount of fuel needed by all modules
  def compute_needed_fuel()
    # init
    fuel = 0
    # loop over modules
    @modules.each do |elem|
      # divide by 3, then floor, then -2
      fuel += (elem/3).floor - 2
    end
    # return result
    fuel
  end

end


# Main file
if __FILE__ == $0
  # init
  aoc = AOC.new

  # compute
  fuel = aoc.compute_needed_fuel

  # print
  print "#{fuel}\n"
end