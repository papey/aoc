package d06

import input.read

fun main() {
    println("Part 1: ${part1(read("06.txt"))}")
    println("Part 2: ${part2(read("06.txt"))}")
}

fun part1(input: List<String>): Long = input
    .map { line -> line.split(" ").mapNotNull { it.toLongOrNull() } }
    .let { (a, b) -> a.zip(b) }
    .fold(1L) { acc, (time, distance) ->
        acc * (0L..time).count { (time - it) * it > distance }
    }

fun part2(input: List<String>): Long = input
    .map { line -> line.replace(Regex("^.*:\\s"), "").replace(" ", "").toLong() }
    .let { (time, distance) -> (0L..time).count { (time - it) * it > distance }.toLong() }
