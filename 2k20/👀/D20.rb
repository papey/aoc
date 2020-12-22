#!/usr/bin/env ruby

require "set"

# all possible sides of a tile
EDGES = [:u, :r, :d, :l].freeze

# Tile class reprensent a tile from the input
class Tile
  attr_reader :pixels
  attr_reader :id
  attr_reader :size

  def initialize(id, pixels, size = 10)
    @pixels = pixels
    @id = id
    @size = size
  end

  def copy
    self.class.new id, pixels, size
  end

  def at(x, y)
    pixels[x][y]
  end

  def column(x)
    pixels.map { _1[x] }
  end

  def columns
    (0..size - 1).map { self.column(_1) }
  end

  def rows
    pixels
  end

  def row(y)
    pixels[y]
  end

  def fliph
    self.class.new id, pixels.map(&:reverse), size
  end

  def rotate
    self.class.new id, pixels.transpose.map(&:reverse), size
  end

  def to_s
    rows.reduce("") { |acc, row| "#{acc}\n#{row.join("")}" }
  end

  def crop
    self.class.new id, self.rows[1..-2].map { _1[1..-2] }, size - 2
  end

  def combinations
    # the exemple I wrote on a paper said that this is all possible combinations
    # so this is the truth !
    r1 = self.rotate
    r2 = r1.rotate
    r3 = r2.rotate
    f = self.fliph
    fr1 = f.rotate
    fr2 = fr1.rotate
    fr3 = fr2.rotate
    # kudos @monique
    [self, r1, r2, r3, f, fr1, fr2, fr3]
  end

  def match_edge?(edge, target)
    # self  target
    # ###   000
    # ###   000
    # ###   000
    # eg, up :
    # 000 - target (bottom)
    # ### - self (up)
    case edge
    when :u
      return true if self.row(0) == target.row(self.size - 1)
    when :r
      return true if self.column(self.size - 1) == target.column(0)
    when :d
      return true if self.row(self.size - 1) == target.row(0)
    when :l
      return true if self.column(0) == target.column(self.size - 1)
    end
    false
  end

  def match(target)
    target.combinations.each do |combi|
      EDGES.each do |edge|
        return [edge, combi] if self.match_edge? edge, combi
      end
    end
    nil
  end

  def search(monster)
    # a copy where monster can be replaced
    with_monster = self.copy

    # found counter
    found = 0

    # monster x size
    w = monster[0].length
    # monster y size
    h = monster.length

    # for each combination of coords where a monster can be contained
    xx = (0..size - w).to_a
    xy = (0..size - h).to_a
    (xx.product xy).each do |x, y|
      # it's a monster until it's not
      is_monster = true
      # a set a of coord for this monster
      mpos = []

      # for each monster pixel
      monster.each_with_index do |mrow, my|
        mrow.each_with_index do |mpixel, mx|
          # if it's not monster pixel, go next
          next if mpixel == " "

          # if it's a monster pixel, check if shifted coords contains the # pixel
          if self.at(x + mx, y + my) != "#" then
            # if not it's not a monster
            is_monster = false
            break
          end

          # save pos
          mpos << [y + my, x + mx]
        end

        # no need to continue if not a monster
        break unless is_monster
      end
      if is_monster then
        found += 1
        mpos.each do |y, x|
          with_monster.pixels[y][x] = "●"
        end
      end
    end
    [found, with_monster]
  end

  def count_waters()
    self.rows.reduce(0) { |acc, r| acc + r.filter { |pix| pix == "#" }.count }
  end

end

# input parsing
tiles = Hash[File.read(ARGV[0]).split("\n\n").map do |tile|
  lines = tile.split("\n")
  id = lines[0].split[1][0..-2].to_i
  [id, Tile.new(id, lines[1..].map { _1.chars })]
end]

# part 1 resolution
# ---
counter = Hash.new 0

# for all values
tiles.values.each do |t|
  # remove current tile from list (do not check a tile with itself)
  attempts = tiles.values - [t]
  attempts.each do |attempt|
    counter[t.id] += 1 if t.match(attempt)
  end
end

# print part 1 answer
# ---
puts counter.select { _2 == 2 }.map { |k, _v| k}.reduce(1) { |product, id| product * id }

# part 2 resolution
# ---
# assemble using a backtrack algorithm
def assemble(tiles, used, picture, row, col, size)
  # end recursion col or row is outside the grid
  return true if col == size || row == size

  tiles.each do |tile|
    id = tile.id
    next if used.include?(id)

    # set candidate
    used.add(id)

    # search for each combinations
    tile.combinations.each do |combi|
      picture[row][col] = combi

      # check left, if not needed it's a match (true by default)
      lfit = col > 0 ? combi.match_edge?(:l, picture[row][col - 1]) : true
      # check down, if not needed it's a match (true by default)
      ufit = row > 0 ? combi.match_edge?(:u, picture[row - 1][col]) : true

      # match
      if lfit && ufit then
        # compute next row and col
        nrow = ((size*row + col + 1) / size).floor
        ncol = ((col + 1) % size).floor
        # check if a subsolution exists
        return true if assemble(tiles, used, picture, nrow, ncol, size)
      end
    end

    # if not, remove the used candidate
    used.delete(id)
  end

  # if nothing is found, just return false
  false
end

def join(picture, size)
  # number of tiles
  ntiles = size / picture[0][0].size
  joined = Array.new(size) { Array.new(size) }

  (0..size - 1).each do |outr|
    # inner row
    ir = (outr / picture[0][0].size).floor
    # row inside the current tile (inner inner row)
    iir = (outr % picture[0][0].size)

    # joined the outer row
    joined[outr] = (0..ntiles - 1).reduce([]) { |acc, ic| acc << picture[ir][ic].row(iir) }.flatten
  end
  joined
end

# compute size
size = Math.sqrt(tiles.length)

# init picture parts
parts = Array.new(size) { Array.new(size) }

# just the tiles
tiles = tiles.map { |k, v| v }

# assemble
assemble(tiles, Set.new, parts, 0, 0, size)

# init picture for cropped data
picture = Array.new(size) { Array.new(size) }

# for each parts
(0..size - 1).each do |row|
  (0..size - 1).each do |line|
    # crop
    picture[row][line] = parts[row][line].crop
  end
end

picture = join(picture, 8 * size.floor)

tile = Tile.new(0, picture, 8 * size.floor)

MONSTER = [
  '                  # ',
  '#    ##    ##    ###',
  ' #  #  #  #  #  #   '
]

m = MONSTER.map(&:chars)

tile.combinations.each do |combi|
  result = combi.search m
  if result[0] != 0 then
    # puts result
    puts tile.count_waters - result[0] * MONSTER.reduce(0) { |acc, row| acc + row.chars.filter { |pix| pix == "#" }.count }
    # puts final tile with monster
    puts result[1]
    exit 0
  end
end
