package d09

import input.read

fun main() {
    println("Part 1: ${part1(read("09.txt"))}")
    println("Part 2: ${part2(read("09.txt"))}")
}

fun part1(input: List<String>): Int = input
    .map { line ->
        line.split(" ")
            .map { it.toInt() }
    }
    .map { numbers ->
        val history: List<List<Int>> = mutableListOf(numbers.toMutableList())
        // predict
        while (!history.last().all { it == 0 }) {
            val next =
                history.last().zip(history.last().subList(1, history.last().size)).map { it.second - it.first }
            history.addLast(next.toMutableList())
        }

        // extrapolate: add 0 to list of 0
        history.last().addLast(0)

        history.indices.reversed().drop(1).forEach {
            history[it].addLast(history[it + 1].last() + history[it].last())
        }

        history
    }.sumOf { it.first().last() }

fun part2(input: List<String>): Int = input
    .map { line ->
        line.split(" ")
            .map { it.toInt() }
    }
    .map { numbers ->
        val history: List<List<Int>> = mutableListOf(numbers.toMutableList())
        // predict
        while (!history.last().all { it == 0 }) {
            val next =
                history.last().reversed().zip(history.last().reversed().subList(1, history.last().size))
                    .map { it.first - it.second }
            history.addLast(next.reversed().toMutableList())
        }

        // extrapolate: add 0 to list of 0
        history.last().addFirst(0)

        history.indices.reversed().drop(1).forEach {
            history[it].addFirst(history[it].first() - history[it + 1].first())
        }

        history
    }.sumOf { it.first().first() }
