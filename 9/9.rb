#!/usr/bin/env ruby

# usefull methods
# pad op to ensure valid data before handling op case
def ops(current)
    padded = sprintf "%05d", current
    return padded[3..5].to_i, padded[2].to_i, padded[1].to_i, padded[0].to_i
end

# get multiple params
def get_params(mem, m1, m2, opidx, rb)
    return get_param(mem, m1, opidx + 1, rb), get_param(mem, m2, opidx + 2, rb)
end

# get addr in multiple mode
def get_addr(mem, m, index, rb)
    # position mode
    if m == 0
        return mem[index]
    end

    # relative base mode
    if m == 2
        return mem[index] + rb
    end

    puts "💥 Error, unsupported mode, abort mission 💥"

    return 0
end

# get a single param
def get_param(mem, m, index, rb)
    # position mode
    if m == 0
        return mem[mem[index]]
    end

    # value mode
    if m == 1
        return mem[index]
    end

    # relative base mode
    if m == 2
        return mem[mem[index] + rb]
    end

    puts "💥 Error, unsupported mode, abort mission 💥"

    return 0
end

# verify and return result
def verify(buffer)
    if buffer[0..buffer.length-2].uniq.length == 1
        return buffer.last
    else
        puts buffer
        raise "Error, validation of self-checks failed"
    end
end

# run intcode computer
def run(mem, input)

    # relative base
    rb = 0

    # output buffer
    buffer = []

    # index pointer
    index = 0

    # loop until instruction code 99
    loop do

        opcode, m1, m2, m3 = ops mem[index]

        case opcode
        # end
        when 99
            return buffer
        # add
        when 1
            p1, p2 = get_params mem, m1, m2, index, rb
            mem[get_addr mem, m3, index + 3, rb] = p1 + p2
            index += 4
        # multiply
        when 2
            p1, p2 = get_params mem, m1, m2, index, rb
            mem[get_addr mem, m3, index + 3, rb] = p1 * p2
            index += 4
        # input
        when 3
            mem[get_addr mem, m3, index + 3, rb] = input
            index += 2
        # output
        when 4
            val = get_param mem, m1, index + 1, rb
            buffer << val
            index += 2
        # jump-if-true
        when 5
            p1, p2 = get_params mem, m1, m2, index, rb
            if p1 != 0
                index = p2
            else
                index += 3
            end
        # jump-if-false
        when 6
            p1, p2 = get_params mem, m1, m2, index, rb
            if p1 == 0
                index = p2
            else
                index += 3
            end
        # less
        when 7
            p1, p2 = get_params mem, m1, m2, index, rb
            if p1 < p2
                mem[get_addr mem, m3, index+3, rb] = 1
            else
                mem[get_addr mem, m3, index+3, rb] = 0
            end
            index += 4
        when 8
            p1, p2 = get_params mem, m1, m2, index, rb
            if p1 == p2
                mem[get_addr mem, m3, index+3, rb] = 1
            else
                mem[get_addr mem, m3, index+3, rb] = 0
            end
            index +=4
        when 9
            p1 = get_param mem, m1, index + 1, rb
            rb += p1
            index += 2
        else
            puts "Unsupported OPcode"
        end
    end
end

# check args
if ARGV.length < 1
    puts "Santa is not happy, some of the arguments are missing"
    exit 1
end

# read content
content = File.read(ARGV[1]).split(",")

# map content to memory
# use 0 as default value
memory = Hash.new(0)

# translate a array to an hash
content.each_with_index do |elem, index|
    memory[index.to_i] = elem.to_i
end

# run the int computer
out = run memory, 1

# verify and get final result
res = verify(out)

#  puts final result
puts "Result, part 1 : " + res.to_s

out = run memory, 2

# verify and get final result
res = verify(out)

#  puts final result
puts "Result, part 2 : " + res.to_s
