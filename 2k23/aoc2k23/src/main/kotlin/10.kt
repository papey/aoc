package d10

import input.read
import java.util.*

fun main() {
    println("Part 1: ${part1(read("10.txt"))}")
    println("Part 2: ~${part2(read("10.txt"))}, you need to debug a bit by yourself ¯\\_(ツ)_/¯")
}

fun part1(input: List<String>): Int {
    val maze = Maze(input)

    val start = maze.getStart()!!
    maze.setDistance(start, 0)

    val queue: Queue<List<Point>> = Direction.entries.filter { dir ->
        val adj = maze.adjacents(start.to(dir))
        adj.any { it == start }
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
            if (it != prev) {
                queue.add(listOf(it, point))
            }
        }
    }
}

fun part2(input: List<String>): Int {
    val maze = Maze(input)

    val start = maze.getStart()!!
    maze.setDistance(start, 0)
    maze.setInside(start, 'S')

    val stack: Stack<List<Point>> = Direction.entries.filter { dir ->
        if (!maze.isValid(start.to(dir))) {
            false
        } else {
            val adj = maze.adjacents(start.to(dir))
            adj.any { it == start }
        }
    }.map {
        listOf(start.to(it), start)
    }.let {
        val s: Stack<List<Point>> = Stack()
        s.addAll(it)
        s
    }

    while (true) {
        val (point, prev) = stack.pop()

        if (point == start) {
            maze.enclosed()
            maze.printInside()
            return maze.countInside()
        }

        maze.discover(point)

        maze.adjacents(point).forEach {
            if (it != prev) {
                stack.push(listOf(it, point))
            }
        }
    }
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

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is Point) return false

        return x == other.x && y == other.y
    }

    override fun hashCode(): Int {
        var result = x
        result = 31 * result + y
        return result
    }
}

class Maze(input: List<String>) {
    private val h: Int = input.size
    private val w: Int = input.first().toCharArray().size
    val map: List<CharArray> = input.map { it.toCharArray() }
    private val distances: List<MutableList<Int>> = List(map.size) { MutableList(map[0].size) { -1 } }
    private val inside: List<MutableList<Char>> = List(map.size) { MutableList(map[0].size) { ' ' } }

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

    fun printInside() {
        (0..<h).forEach { y ->
            (0..<w).forEach { x ->
                print(getInside(Point(x, y)))
            }
            println()
        }
    }

    fun getValue(point: Point): Char = map[point.y][point.x]

    fun setDistance(point: Point, dist: Int) {
        distances[point.y][point.x] = dist
    }

    fun getDistance(point: Point): Int = distances[point.y][point.x]

    private fun getInside(point: Point): Char = inside[point.y][point.x]

    fun setInside(point: Point, value: Char) {
        inside[point.y][point.x] = value
    }

    fun adjacents(point: Point): List<Point> {
        return SYMBOL_TO_DIRECTION[getValue(point)]!!.filter { dir -> isValid(point.to(dir)) }
            .map { point.to(it) }
    }

    fun discover(point: Point) {
        setInside(point, getValue(point))
    }

    fun enclosed() {
        forEachPosition {
            val boundaries = (it.x + 1..<w).count { x ->
                val boundary = getInside(Point(x, it.y))
                listOf('|', 'J', 'L').contains(boundary)
            }

            if (getInside(it) == ' ') {
                setInside(
                    it, if (boundaries % 2 == 0) {
                        'O'
                    } else {
                        'I'
                    }
                )
            }
        }
    }

    fun countInside(): Int {
        var count = 0

        forEachPosition {
            if (getInside(it) == 'I') {
                count++
            }
        }

        return count
    }

    private fun forEachPosition(operation: (Point) -> Unit) {
        (0..<h).forEach { y ->
            (0..<w).forEach { x ->
                operation(Point(x, y))
            }
        }
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
