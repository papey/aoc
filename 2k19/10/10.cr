# Check args
if ARGV.size < 1
  abort "Santa is not happy, please provide arguments"
end

# Read file
path = ARGV[0]
# Check if file exists
abort "File `" + path + "` is missing", 1 if !File.file? path
# Read file and split data into a 2D map array
map = File.read(path).split("\n").map { |e| e.split "" }

# Hash containing results
results = {} of Int32 => Tuple(Int32, Int32)

# loop over all points in the map
# this is the base asteroïd
map.each_with_index do |elem, j|
  elem.each_with_index do |_, i|
    # if it's not as asteroïd, go next
    if map[j][i] == "."
      next
    end
    # if it's an asteroïd
    # set counter to 0
    c = 0
    # reloop over everything, go full brute force
    # this is the current asteroïd
    map.each_with_index do |cur, y|
      cur.each_with_index do |_, x|
        # is asteroïd found ?
        found = false
        # if current position is not as asteroïd, go next
        if map[y][x] == "."
          next
        end
        # compute gcd, unsure we get the direction
        gcd = (x - i).gcd(y - j).abs
        # ensure gcd is ok
        if gcd != nil
          # loop over all gcd (in fact, all points in space on this vector)
          (1..gcd - 1).each do |m|
            # fetch element, using gcd to go from current asteroïd to base
            e = map[j + ((y - j) / gcd * m).to_i][i + ((x - i) / gcd * m).to_i]
            # if element is an asteroïd, there is a asteroïd on the line
            if e == "#"
              # asteroïd is found
              found = true
              # go next
              break
            end
          end
          # if there is no asteroïd
          if !found
            # increment asteroïd counter
            c += 1
          end
        end
      end
    end
    # add result to map
    results[c] = {i, j}
  end
end

# do not count yourself, fetch max from keys in hash
puts "Result, part 1 : " + (results.max[0] - 1).to_s
