package d11

import input.read
import kotlin.math.abs
import kotlin.math.min

fun main() {
    println("Part 1: ${part1(read("11.txt"))}")
    println("Part 2: ${part2(read("11.txt"))}")
}

fun part1(input: List<String>): Long {
    val galaxy = Supercluster(input)

    return galaxy.eachGalaxyPair().sumOf(galaxy::distance)
}

fun part2(input: List<String>): Long {
    val galaxy = Supercluster(input)

    return galaxy.eachGalaxyPair().sumOf { galaxy.distance(it, 1000000L) }
}

class Point(val x: Long, val y: Long)

class Supercluster(input: List<String>) {
    private val EMPTY_SPACE = '.'
    private val GALAXY = '#'

    val map = input.map { it.toCharArray().toMutableList() }.toMutableList()
    private val h = map.size
    private val w = map.first().size

    private val extraLines = (0L..<h).filter { y ->
        (0L..<w).all { x ->
            getValue(Point(x, y)) == EMPTY_SPACE
        }
    }

    private val extraRows = (0L..<w).filter { x ->
        (0L..<h).all { y ->
            getValue(Point(x, y)) == EMPTY_SPACE
        }
    }

    private val galaxies = (0L..<h).flatMap { y ->
        (0L..<w).filter { x ->
            getValue(Point(x, y)) == GALAXY
        }.map { Point(it, y) }
    }

    fun getValue(point: Point): Char = map[point.y.toInt()][point.x.toInt()]

    fun eachGalaxyPair(): List<Pair<Point, Point>> = galaxies.indices.flatMap { i ->
        (i.inc()..<galaxies.size).map { j ->
            Pair(galaxies[i], galaxies[j])
        }
    }

    fun distance(galaxies: Pair<Point, Point>, jump: Long = 2L): Long {
        val (g1, g2) = galaxies

        val ox = min(g2.x, g1.x)
        val oy = min(g2.y, g1.y)

        val dx = abs(g2.x - g1.x)
        val dy = abs(g2.y - g1.y)

        val d = dx + dy

        val jumps = (ox..ox + dx).count { x -> extraRows.contains(x) } +
                (oy..oy + dy).count { y -> extraLines.contains(y) }

        return d + jumps * (jump - 1)
    }
}
