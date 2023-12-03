package d03

import input.read

fun main() {
    val (numbers, symbols) = parseMap(read("03.txt"))
    println("Part 1: ${part1(numbers, symbols)}")
    println("Part 2: ${part2(numbers, symbols)}")
}

fun part1(numbers: Numbers, symbols: Symbols): Int {
    return numbers.filter { entry ->
        (0..<entry.value.toString().length).any { bx ->
            intArrayOf(-1, 0, 1).any { dx ->
                intArrayOf(-1, 0, 1).any { dy ->
                    symbols.keys.contains(Pair(entry.key.first + bx + dx, entry.key.second + dy))
                }
            }
        }
    }.values.sum()
}

val GEAR_SYMBOL = '*'
val GEAR_RATIOS = 2

fun part2(numbers: Numbers, symbols: Symbols): Int {
    val numberz: Numbers = numbers.flatMap { (key, value) ->
        (0..<value.toString().length).map {
            Pair(key.first + it, key.second) to value
        }
    }.toMap() as Numbers

    return symbols.filter { it.value == GEAR_SYMBOL }.keys.sumOf {
        val set: MutableSet<Int> = mutableSetOf()
        intArrayOf(-1, 0, 1).forEach { dx ->
            intArrayOf(-1, 0, 1).forEach { dy ->
                val neighbor = Pair(it.first + dx, it.second + dy)
                if (numberz.contains(neighbor)) {
                    set.add(numberz[neighbor]!!)
                }
            }
        }

        if (set.size == GEAR_RATIOS) set.reduce(Int::times) else 0
    }
}

typealias Numbers = HashMap<Pair<Int, Int>, Int>
typealias Symbols = HashMap<Pair<Int, Int>, Char>

fun parseMap(lines: List<String>): Pair<Numbers, Symbols> {
    val numbers: Numbers = hashMapOf()
    val symbols: Symbols = hashMapOf()

    val regex = """\d+""".toRegex()

    lines.forEachIndexed { y, s ->
        var x = 0
        var currentLine = s

        while (currentLine.isNotEmpty()) {
            val currentChar = currentLine.first()
            if (currentChar.isDigit()) {
                val match = regex.find(currentLine)!!
                val num = match.value.toInt()
                numbers[Pair(x, y)] = num
                x += match.value.length
                currentLine = currentLine.substring(match.value.length)
            } else {
                if (currentChar != '.') {
                    symbols[Pair(x, y)] = currentChar
                }
                x += 1
                currentLine = currentLine.substring(1)
            }
        }
    }

    return Pair(numbers, symbols)
}
