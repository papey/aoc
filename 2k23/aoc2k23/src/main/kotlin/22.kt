package d22

import input.read
import kotlin.math.max
import kotlin.math.min

fun main() {
    println("Part 1: ${part1(read("22.txt"))}")
    println("Part 2: ${part2(read("22.txt"))}")
}

fun part1(input: List<String>): Int {
    val bricks = input.map { Brick(it) }.toMutableList()

    val (supports, supportedBy) = stabilize(bricks)

    return bricks.filterIndexed { index, _ -> supports[index]!!.all { supportedBy[it]!!.size > 1 } }.size
}

fun part2(input: List<String>): Int {
    val bricks = input.map { Brick(it) }.toMutableList()

    val (supports, supportedBy) = stabilize(bricks)

    return bricks.foldIndexed(0) { index, acc, _ ->
        val queue = ArrayDeque(supports[index]!!.filter { supportedBy[it]!!.size == 1 })
        val falling = mutableSetOf<Int>()
        queue.forEach { falling.add(it) }
        falling.add(index)

        while (queue.isNotEmpty()) {
            val current = queue.removeFirst()
            supports[current]!!.minus(falling).filter { supportedBy[it]!!.all { element -> element in falling } }
                .forEach {
                    queue.add(it)
                    falling.add(it)
                }

        }

        acc + falling.size - 1
    }
}

fun stabilize(bricks: MutableList<Brick>): Pair<Map<Int, MutableSet<Int>>, Map<Int, MutableSet<Int>>> {
    bricks.sortBy { it.start.z }

    bricks.forEachIndexed { index, brick ->
        var max = 1

        bricks.subList(0, index).forEach { lowerBricks ->
            if (brick.overlaps(lowerBricks)) {
                max = max(max, lowerBricks.end.z + 1)
            }
        }

        brick.end.z -= brick.start.z - max
        brick.start.z = max
    }

    bricks.sortBy { it.start.z }

    val supports = (0..<bricks.size).associateWith { mutableSetOf<Int>() }
    val supportedBy = (0..<bricks.size).associateWith { mutableSetOf<Int>() }

    bricks.forEachIndexed { upperIndex, upperBrick ->
        bricks.forEachIndexed { lowerIndex, lowerBrick ->
            if (upperBrick.overlaps(lowerBrick) && upperBrick.start.z == lowerBrick.end.z + 1) {
                supports[lowerIndex]!!.add(upperIndex)
                supportedBy[upperIndex]!!.add(lowerIndex)
            }
        }
    }

    return supports to supportedBy
}

class Brick(input: String) {
    val start: Point
    val end: Point

    init {
        val (rawStart, rawEnd) = input.split("~")

        val startCoord = rawStart.split(",").map { it.toInt() }
        start = Point(startCoord[0], startCoord[1], startCoord[2])

        val endCoord = rawEnd.split(",").map { it.toInt() }
        end = Point(endCoord[0], endCoord[1], endCoord[2])
    }

    fun overlaps(other: Brick): Boolean =
        max(start.x, other.start.x) <= min(end.x, other.end.x) && max(start.y, other.start.y) <= min(end.y, other.end.y)

}

data class Point(val x: Int, val y: Int, var z: Int)
