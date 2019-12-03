# Check args
if ARGV.size < 1
  abort "Santa is not happy, please provide arguments"
end

# Read file
path = ARGV[0]
# Check if file exists
abort "File `" + path + "` is missing", 1 if !File.file? path
# Read file
memory = File.read(path).split(",").map { |e| e.to_i }

# resolve function
def resolve(mem : Array(Int32), noun : Int32, verb : Int32)
  # index
  i : Int32 = 0

  # restore gravity
  mem[1] = noun
  mem[2] = verb

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

#  BRUTE FORCE
def resolve_full(mem : Array(Int32), expect : Int32)
  # init loops
  noun = 0
  verb = 0
  while noun != 100
    while verb != 100
      # compute
      computed = resolve(mem.clone, noun, verb)
      # check if result is the one expected
      if computed[0] == expect
        # return computed output
        return output(noun, verb)
      end
      # more force
      verb += 1
    end
    # more and more force
    noun += 1
    # do not forget do init the force again
    verb = 0
  end

  abort "Solution not found"
end

# Compute output as specified in challenge
def output(noun : Int32, verb : Int32)
  return 100 * noun + verb
end

# Part one
if ARGV.size == 1
  computed = resolve(memory.clone, 12, 2)
  puts "Result : " + computed[0].to_s
end

# Part two
if ARGV.size == 2
  result = resolve_full(memory.clone, ARGV[1].to_i)
  puts "Result : " + result.to_s
end
