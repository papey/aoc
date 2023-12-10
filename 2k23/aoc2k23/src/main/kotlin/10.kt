package d10

import input.read
import java.util.*

fun main() {
    println("Part 1: ${part1(read("10.txt"))}")
//    println("Part 2: ${part2(read("10.txt"))}")
}

fun part1(input: List<String>): Int {
    val maze = Maze(input)

    val start = maze.getStart()!!
    maze.setDistance(start, 0)

    val queue: Queue<List<Point>> = Direction.entries.filter { dir ->
        val adj = maze.adjacents(start.to(dir))
        adj.any { it.x == start.x && it.y == start.y }
    }.map {
        listOf(start.to(it), start)
    }.let {
        LinkedList(it)
    }

    while (true) {
        val (point, prev) = queue.poll()

        if (maze.getDistance(point) != -1) {
            return maze.getDistance(point)
        }

        maze.setDistance(point, maze.getDistance(prev) + 1)

        maze.adjacents(point).forEach {
            if (it.x != prev.x || it.y != prev.y) {
                queue.add(listOf(it, point))
            }
        }
    }
}

fun part2(input: List<String>): Int {
    return 0
}

class Point(val x: Int, val y: Int) {
    fun to(dir: Direction): Point {
        return when (dir) {
            Direction.WEST -> Point(x - 1, y)
            Direction.NORTH -> Point(x, y - 1)
            Direction.SOUTH -> Point(x, y + 1)
            Direction.EAST -> Point(x + 1, y)
        }
    }
}

class Maze(input: List<String>) {
    private val h: Int = input.size
    private val w: Int = input.first().toCharArray().size
    val map: List<CharArray> = input.map { it.toCharArray() }
    private val distances: List<MutableList<Int>> = List(map.size) { MutableList(map[0].size) { -1 } }

    fun isValid(point: Point): Boolean = point.x in 0..<w && point.y in 0..<h

    fun getStart(): Point? {
        (0..<h).forEach { y ->
            (0..<w).forEach { x ->
                if (map[y][x] == 'S') {
                    return Point(x, y)
                }
            }
        }

        return null
    }

    fun setDistance(point: Point, dist: Int) {
        distances[point.y][point.x] = dist
    }

    fun getDistance(point: Point): Int = distances[point.y][point.x]

    fun adjacents(point: Point): List<Point> {
        return SYMBOL_TO_DIRECTION[map[point.y][point.x]]!!.filter { dir -> isValid(point.to(dir)) }
            .map { point.to(it) }
    }
}

enum class Direction {
    NORTH,
    SOUTH,
    EAST,
    WEST;
}

private val SYMBOL_TO_DIRECTION: Map<Char, List<Direction>> =
    hashMapOf(
        '|' to listOf(Direction.NORTH, Direction.SOUTH),
        '-' to listOf(Direction.WEST, Direction.EAST),
        'L' to listOf(Direction.NORTH, Direction.EAST),
        'J' to listOf(Direction.NORTH, Direction.WEST),
        '7' to listOf(Direction.WEST, Direction.SOUTH),
        'F' to listOf(Direction.EAST, Direction.SOUTH),
        '.' to listOf()
    )
