package d16

import java.util.*
import java.util.concurrent.Callable
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

fun main() {
    println("Part 1: ${part1(input.read("16.txt"))}")
    println("Part 2: ${part2(input.read("16.txt"))}")
}

fun part1(input: List<String>): Int = Maze(input).simulate(Maze.Point(0, 0), Maze.Direction.East)

fun part2(input: List<String>): Int = Maze(input).findMostEnergized()

class Maze(input: List<String>) {
    class Point(val x: Int, val y: Int) {
        fun move(delta: Point): Point = Point(x + delta.x, y + delta.y)

        override fun hashCode(): Int {
            var result = x
            result = 32 * result + y
            return result
        }

        override fun equals(other: Any?): Boolean {
            if (this === other) return true
            if (javaClass != other?.javaClass) return false

            other as Point

            if (x != other.x) return false
            if (y != other.y) return false

            return true
        }
    }

    enum class Direction(val point: Point) {
        North(Point(0, -1)),
        South(Point(0, 1)),
        East(Point(1, 0)),
        West(Point(-1, 0)),
    }

    private val grid = input.map { it.toCharArray() }

    private val xMax = input[0].length
    private val yMax = input.size

    private val moves = mapOf(
        '/' to Direction.North to listOf(Direction.East),
        '/' to Direction.West to listOf(Direction.South),
        '/' to Direction.South to listOf(Direction.West),
        '/' to Direction.East to listOf(Direction.North),
        '|' to Direction.East to listOf(Direction.North, Direction.South),
        '|' to Direction.West to listOf(Direction.North, Direction.South),
        '-' to Direction.North to listOf(Direction.East, Direction.West),
        '-' to Direction.South to listOf(Direction.East, Direction.West),
        '\\' to Direction.North to listOf(Direction.West),
        '\\' to Direction.West to listOf(Direction.North),
        '\\' to Direction.South to listOf(Direction.East),
        '\\' to Direction.East to listOf(Direction.South)
    )

    fun get(point: Point): Char = grid[point.y][point.x]

    fun simulate(position: Point, direction: Direction): Int {
        val visited = mutableSetOf(position to direction)

        val toVisit = LinkedList<Pair<Point, Direction>>()

        toVisit.add(position to direction)

        while (toVisit.isNotEmpty()) {
            val (pos, dir) = toVisit.pop()

            (moves[get(pos) to dir] ?: listOf(dir)).forEach { nextDir ->
                val nextPos = pos.move(nextDir.point)
                val next = nextPos to nextDir

                if (next !in visited && inBound(nextPos)) {
                    toVisit.add(nextPos to nextDir)
                    visited.add(next)
                }

            }
        }

        return visited.map { it.first }.toSet().size
    }

    fun findMostEnergized(): Int {
        val executor: ExecutorService = Executors.newFixedThreadPool(5)

        val tasks = listOf(
            Callable { grid.first().indices.map { Point(it, 0) to Direction.South } },
            Callable { grid.last().indices.map { Point(it, yMax - 1) to Direction.North } },
            Callable { grid.indices.map { Point(0, it) to Direction.East } },
            Callable { grid.indices.map { Point(xMax - 1, it) to Direction.West } }
        )

        val futures = executor.invokeAll(tasks)
        val results = futures.map { it.get() }.flatten().map { simulate(it.first, it.second) }

        executor.shutdown()

        return results.maxOrNull() ?: 0
    }

    private fun inBound(point: Point): Boolean = (point.x in 0..<xMax) && (point.y in 0..<yMax)
}
