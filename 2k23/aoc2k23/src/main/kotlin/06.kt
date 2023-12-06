package d06

import input.read
import kotlin.math.*

fun main() {
    println("Part 1: ${part1(read("06.txt"))}")
    println("Part 2: ${part2(read("06.txt"))}")
}

fun part1(input: List<String>): Long = input
    .map { line -> line.split(" ").mapNotNull { it.toLongOrNull() } }
    .let { (a, b) -> a.zip(b) }
    .fold(1L) { acc, (time, distance) ->
        acc * solve(-time.toDouble(), distance.toDouble())
    }

fun part2(input: List<String>): Long = input
    .map { line -> line.replace(Regex("^.*:\\s"), "").replace(" ", "").toLong() }
    .let { (time, distance) -> solve(-time.toDouble(), distance.toDouble()) }

private fun solve(b: Double, c: Double): Long {
    val det = b * b - 4 * c
    val r1 = (-b - sqrt(det)) / 2.0
    val r2 = (-b + sqrt(det)) / 2.0

    val cr1 = ceil(r1)
    val cr2 = ceil(r2)
    val res = abs(cr1 - cr2).toLong()

    return if (cr1 == r1 && cr2 == r2) return res - 1 else res
}
