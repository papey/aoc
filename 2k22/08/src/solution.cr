require "../../helpers/input"

module Day07
  def self.part1
    input = Input.new("../input/in")

    grid = parse_grid(input)
    length, width = sizes(grid)

    result = grid.each_with_index.map do |row, y|
      row.each_with_index.map do |tree, x|
        (x + 1..length).all? { |xx| row[xx] < tree } ||
          (0...x).all? { |xx| row[xx] < tree } ||
          (y + 1..width).all? { |yy| grid[yy][x] < tree } ||
          (0...y).all? { |yy| grid[yy][x] < tree }
      end.to_a
    end.to_a

    result.flatten.select(&.itself).size
  end

  def self.part2
    input = Input.new("../input/in")

    grid = parse_grid(input)
    length, width = sizes(grid)

    grid.each_with_index.max_of do |row, y|
      row.each_with_index.max_of do |tree, x|
        x0 = (x + 1).upto(length).index { |xx| row[xx] >= tree }.try(&.+ 1) || length - x
        x1 = (x - 1).downto(0).index { |xx| row[xx] >= tree }.try(&.+ 1) || x
        y0 = (y + 1).upto(width).index { |yy| grid[yy][x] >= tree }.try(&.+ 1) || width - y
        y1 = (y - 1).downto(0).index { |yy| grid[yy][x] >= tree }.try(&.+ 1) || y
        [x0, x1, y0, y1].product
      end
    end
  end

  private def self.parse_grid(input)
    input.lines(cleanup: true).map(&.split("").map(&.to_i))
  end

  private def self.sizes(grid)
    [grid[0].size - 1, grid.size - 1]
  end
end

puts "Part 1 : #{Day07.part1}"

puts "Part 2 : #{Day07.part2}"
