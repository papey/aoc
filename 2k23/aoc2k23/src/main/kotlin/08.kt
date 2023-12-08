package d08

import input.raw

fun main() {
    println("Part 1: ${part1(raw("08.txt"))}")
    println("Part 2: ${part2(raw("08.txt"))}")
}

enum class Direction {
    Left,
    Right,
    None;

    companion object {
        fun fromChar(c: Char): Direction = when (c) {
            'R' -> Right
            'L' -> Left
            else -> None
        }
    }
}

typealias Nodes = MutableMap<String, Pair<String, String>>

fun parseInput(input: String): Pair<List<Direction>, Nodes> = input.split("\n\n").let { parts ->
    val instructions = parts.first().toCharArray().map { Direction.fromChar(it) }
    val regex = Regex("(\\w+) = \\((\\w+), (\\w+)\\)")

    val nodes: Nodes = parts[1].split("\n").filter { it.isNotBlank() }.fold(mutableMapOf()) { acc, line ->
        val groups = regex.find(line)!!.groupValues
        acc[groups[1]] = Pair(groups[2], groups[3])
        acc
    }

    Pair(instructions, nodes)
}

const val END_NODE = "ZZZ"

fun traverse(start: String, nodes: Nodes, instructions: List<Direction>, isEndReached: (String) -> Boolean): Int {
    var currentNode = start
    val directions = generateSequence { instructions }.flatten().iterator()

    return directions.asSequence().takeWhile {
        val node = nodes[currentNode]!!
        currentNode = if (it == Direction.Left) {
            node.first
        } else {
            node.second
        }
        !isEndReached(currentNode)
    }.count() + 1
}

fun gcd(a: Long, b: Long): Long {
    return if (b == 0L) a else gcd(b, a % b)
}

fun lcm(a: Long, b: Long): Long {
    return if (a == 0L || b == 0L) 0 else (a * b) / gcd(a, b)
}

fun part1(input: String): Int {
    val (instructions, nodes) = parseInput(input)

    return traverse("AAA", nodes, instructions) { node -> node == END_NODE }
}

fun part2(input: String): Long {
    val (instructions, nodes) = parseInput(input)
    val startingNodes = nodes.filter { it.key.endsWith('A') }

    return startingNodes.keys.map {
        traverse(it, nodes, instructions) { node ->
            node.endsWith('Z')
        }
    }.map { it.toLong() }.reduce { acc, v -> lcm(acc, v) }
}
