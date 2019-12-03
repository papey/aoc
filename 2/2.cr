# Check args
if ARGV.size != 1
  abort "Santa is not happy, please provide arguments"
end

# Read file
path = ARGV[0]
# Check if file exists
abort "File `" + path + "` is missing", 1 if !File.file? path
# Read file
memory = File.read(path).split(",").map { |e| e.to_i }

# resolve function
def resolve(mem : Array(Int32), a : Int32, b : Int32)
  # index
  i : Int32 = 0

  # restore gravity
  mem[1] = a
  mem[2] = b

  # while op code is not 99
  while mem[i] != 99
    if mem[i] == 1
      # if one, replace and add
      mem[mem[i + 3]] = mem[mem[i + 1]] + mem[mem[i + 2]]
    elsif mem[i] == 2
      # if two, replace and multiply
      mem[mem[i + 3]] = mem[mem[i + 1]] * mem[mem[i + 2]]
    else
      abort "Not supported OP"
    end
    i += 4
  end
  return mem
end

# Part one
if ARGV.size == 1
  computed = resolve(memory.clone, 12, 2)
  puts "Result : " + computed[0].to_s
end
