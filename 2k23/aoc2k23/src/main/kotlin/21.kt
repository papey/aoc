package d21

import input.read
import java.math.BigInteger

fun main() {
    println("Part 1: ${part1(read("21.txt"))}")
    println("Part 2: ${part2(read("21.txt"))}")
}

fun part1(input: List<String>): Int = Maze(input).discover()

fun part2(input: List<String>): BigInteger {
    val goal = 26501365
    val maze = Maze(input)

    val distToEdge = maze.size / 2
    val n = ((goal - distToEdge) / maze.size).toBigInteger()
    val results = mutableListOf<BigInteger>()

    var visited = mutableSetOf(maze.start)
    var count = 1

    while (true) {
        val nextVisited = mutableSetOf<Maze.Point>()

        visited.forEach { point ->
            nextVisited.addAll(point.neighbours().filter { neighbour ->
                val target = Maze.Point(modulo(neighbour.x, maze.size), modulo(neighbour.y, maze.size))
                maze.get(target) == Maze.Tile.Garden
            })
        }

        visited = nextVisited

        if (count == distToEdge + maze.size * results.size) {
            results.add(visited.size.toBigInteger())

            if (results.size == 3) {
                // Lagrange's interpolation shit
                val a = (results[2] - (BigInteger("2") * results[1]) + results[0]) / BigInteger("2")
                val b = results[1] - results[0] - a
                val c = results[0]
                return (a * (n.pow(2))) + (b * n) + c
            }
        }

        count++
    }
}

fun modulo(dividend: Int, divisor: Int): Int = ((dividend % divisor) + divisor) % divisor

class Maze(input: List<String>) {
    enum class Tile {
        Garden,
        Rock;
    }

    data class Point(val x: Int, val y: Int) {
        fun neighbours(): List<Point> = listOf(
            Point(x - 1, y),
            Point(x + 1, y),
            Point(x, y - 1),
            Point(x, y + 1)
        )
    }

    val map =
        input.map { line ->
            line.map { ch ->
                when (ch) {
                    '#' -> Tile.Rock
                    '.' -> Tile.Garden
                    'S' -> Tile.Garden
                    else -> throw Exception("Unknown char $ch")
                }
            }
        }

    val start = Point(input.first().length / 2, input.size / 2)

    val size = map.size

    fun get(point: Point): Tile = map[point.y][point.x]

    private fun inBound(point: Point): Boolean =
        point.x >= 0 && point.y >= 0 && point.y < map.size && point.x < map[point.y].size

    fun discover(): Int =
        (1..64).fold(mutableSetOf(start)) { acc, _ ->
            acc.fold(mutableSetOf()) { next, point ->
                next.addAll(point.neighbours()
                    .filter { inBound(it) }
                    .filter { get(it) == Tile.Garden })
                next
            }
        }.size
}
