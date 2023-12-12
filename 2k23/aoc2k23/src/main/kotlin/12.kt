package d12

import input.read

fun main() {
    println("Part 1: ${part1(read("12.txt"))}")
    println("Part 2: ${part2(read("12.txt"))}")
}

fun part1(input: List<String>): Long = input.sumOf {
    val (springs, sizes) = it.split(" ").let { parts ->
        val springs = parts.first().toCharArray().toList()
        // ensure group is closed
        springs.addLast('.')
        Pair(springs, parts[1].split(",").map { number -> number.toInt() })
    }

    solve(springs, sizes)
}

fun part2(input: List<String>): Long = input.sumOf {
    val (springs, sizes) = it.split(" ").let { parts ->
        val baseSprings = parts.first()
        val springs = List(5) { baseSprings }.joinToString("?").toMutableList()

        // ensure group is closed
        springs.addLast('.')

        val baseSizes = parts[1].split(",").map { number -> number.toInt() }
        Pair(springs, List(5) { baseSizes }.flatten())
    }

    solve(springs, sizes)
}


class State(private val springs: List<Char>, private val sizes: List<Int>, private val doneInGroup: Int) {
    override fun hashCode(): Int {
        return 31 * springs.hashCode() + sizes.hashCode() + doneInGroup.hashCode()
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as State

        if (springs != other.springs) return false
        if (sizes != other.sizes) return false
        if (doneInGroup != other.doneInGroup) return false

        return true
    }
}

fun solve(springs: List<Char>, sizes: List<Int>): Long = solve(springs, sizes, 0, hashMapOf())

fun solve(springs: List<Char>, sizes: List<Int>, doneInGroup: Int, memo: MutableMap<State, Long>): Long {
    if (springs.isEmpty()) {
        if (sizes.isEmpty() && doneInGroup == 0) {
            return 1
        }

        return 0
    }

    val state = State(springs, sizes, doneInGroup)
    if (memo.containsKey(state)) {
        return memo[state]!!
    }

    var solutions = 0L

    val candidates = if (springs.first() == '?') listOf('#', '.') else listOf(springs.first())

    candidates.forEach { c ->
        when (c) {
            '#' -> {
                solutions += solve(springs.drop(1), sizes, doneInGroup + 1, memo)

            }

            '.' -> {
                if (doneInGroup != 0) {
                    if (sizes.isNotEmpty() && sizes.first() == doneInGroup) {
                        solutions += solve(springs.drop(1), sizes.drop(1), 0, memo)
                    }
                } else {
                    solutions += solve(springs.drop(1), sizes, 0, memo)
                }
            }
        }

    }

    memo[state] = solutions

    return solutions
}
