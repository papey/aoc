package d23

import input.read

fun main() {
    println("Part 1: ${part1(read("23.txt"))}")
    println("Part 2: ${part2(read("23.txt"))}")
}

fun part1(input: List<String>): Int = Maze(input).findLongestPath()

// C'est Noël, on optimise keud'
fun part2(input: List<String>): Int = Maze(input, false).findLongestPath()

class Maze(input: List<String>, withSlope: Boolean = true) {
    val map = input.mapIndexed { y, line ->
        line.toCharArray().mapIndexed { x, c ->
            val p = Point(x, y)
            when (c) {
                '.' -> Element.Path(p)
                '#' -> Element.Forest(p)
                '^' -> if (withSlope) { Element.Slope(p, Direction.Up) } else { Element.Path(p) }
                'v' -> if (withSlope) { Element.Slope(p, Direction.Down) } else { Element.Path(p) }
                '<' -> if (withSlope) { Element.Slope(p, Direction.Left) } else { Element.Path(p) }
                '>' -> if (withSlope) { Element.Slope(p, Direction.Right) } else { Element.Path(p) }
                else -> throw IllegalStateException("Unknown character: $c")
            }
        }
    }

    private val start = Point(1, 0)
    private val end = Point(map[0].size - 2, map.size - 1)

    fun findLongestPath(): Int {
        return dfs(start, mutableSetOf())
    }

    private fun dfs(point: Point, visited: MutableSet<Point>): Int {
        if (point == end) {
            return 0
        }

        var longestPath = Int.MIN_VALUE

        visited.add(point)
        get(point).neighbours().filter { inBound(it) }.map { get(it) }
            .filter { it is Element.Path || it is Element.Slope }.forEach { neighbour ->
                if (neighbour.point !in visited) {
                    longestPath = maxOf(longestPath, 1 + dfs(neighbour.point, visited))
                }
            }
        visited.remove(point)

        return longestPath
    }

    fun get(point: Point): Element = map[point.y][point.x]

    private fun inBound(point: Point): Boolean =
        point.x >= 0 && point.y >= 0 && point.y < map.size && point.x < map[point.y].size

    sealed class Element(open val point: Point) {
        data class Forest(override val point: Point) : Element(point)
        data class Path(override val point: Point) : Element(point)
        data class Slope(override val point: Point, val direction: Direction) : Element(point) {
            override fun neighbours(): List<Point> = listOf(point.move(direction.point))
        }

        open fun neighbours(): List<Point> = Direction.entries.map { direction -> point.move(direction.point) }
    }
}

enum class Direction(val point: Point) {
    Up(Point(0, -1)),
    Down(Point(0, 1)),
    Left(Point(-1, 0)),
    Right(Point(1, 0))
}

data class Point(val x: Int, val y: Int) {
    fun move(delta: Point): Point = Point(x + delta.x, y + delta.y)
}
