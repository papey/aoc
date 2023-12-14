package d14

fun main() {
    println("Part 1: ${part1(input.read("14.txt"))}")
    println("Part 2: ${part2(input.read("14.txt"))}")
}

fun part1(input: List<String>): Int {
    val platform = Platform(input.map { it.toCharArray() })
    platform.tilt(Platform.Direction.North)

    return platform.load()
}

fun part2(input: List<String>): Int {
    val platform = Platform(input.map { it.toCharArray() })
    val states: MutableMap<String, Int> = mutableMapOf()
    var times = 0
    var remaining = 1000000000

    while (!states.containsKey(platform.state())) {
        states[platform.state()] = times
        platform.cycle()
        times++
    }

    val cycleLen = times - states[platform.state()]!!

    remaining - times
    remaining -= (remaining / cycleLen) * cycleLen

    repeat(remaining) {
        platform.cycle()
    }

    return platform.load()
}


class Platform(input: List<CharArray>) {
    private var dish = input

    private val roundedRock = 'O'
    private val emptySpace = '.'

    enum class Direction {
        North,
        West,
        South,
        East
    }

    fun tilt(dir: Direction) {
        return when (dir) {
            Direction.North -> {
                dish = tiltNorth(dish)
            }

            Direction.East -> {
                val oriented = transpose(dish).reversed()
                val tilted = tiltNorth(oriented)
                dish = transpose(tilted.reversed())
            }

            Direction.West -> {
                dish = transpose(tiltNorth(transpose(dish)))
            }

            Direction.South -> {
                dish = tiltNorth(dish.reversed()).reversed()
            }
        }
    }

    fun cycle() =
        Direction.entries.forEach {
            tilt(it)
        }

    fun state() = dish.joinToString(":") { it.joinToString("") }

    fun load(): Int =
        dish.reversed().mapIndexed { index, chars ->
            chars.count { it == roundedRock } * (index + 1)
        }.sum()


    private fun tiltNorth(originDish: List<CharArray>): List<CharArray> {
        val tiltedDish = originDish.toMutableList()

        originDish.indices.forEach { y ->
            (originDish[0].indices).forEach x@{ x ->
                if (originDish[y][x] != roundedRock) {
                    return@x
                }

                val newY = (0..<y).reversed().takeWhile { originDish[it][x] == emptySpace }.lastOrNull() ?: -1

                if (newY != -1) {
                    tiltedDish[newY][x] = roundedRock
                    tiltedDish[y][x] = emptySpace
                }
            }
        }

        return tiltedDish
    }

    private fun transpose(dish: List<CharArray>): List<CharArray> {
        return dish[0].indices.map { i -> dish.map { it[i] }.toCharArray() }
    }
}
