package d02

import input.read
import java.util.*

fun main() {
    println("Part 1: ${part1(read("02.txt"))}")
    println("Part 2: ${part2(read("02.txt"))}")
}


class Game(input: String) {
    enum class Color {
        BLUE, RED, GREEN
    }

    private val id: Int
    private var rounds: List<Map<Color, Int>>
    private val balls: Map<Color, Int> = mapOf(
        Color.BLUE to 14,
        Color.RED to 12,
        Color.GREEN to 13
    )

    private val GAME_DELIMITOR = ":"
    private val ROUND_DELIMITOR = ";"
    private val INNER_ROUND_DELIMITOR = ", "

    init {
        id = parseId(input)!!
        rounds = parseRuns(input)
    }

    fun isValid(): Boolean {
        return rounds.all { round ->
            round.all { (color, count) ->
                balls[color]!! >= count
            }
        }
    }

    fun getId(): Int {
        return id
    }

    fun getFewest(): Int {
        return rounds.fold(mutableMapOf<Color, Int>()) { acc, round ->
            round.forEach { (color, count) ->
                if (acc.getOrDefault(color, 0) < count) {
                    acc[color] = count
                }
            }

            acc
        }.values.reduce(Int::times)
    }

    private fun parseId(input: String): Int? {
        return Regex("Game (\\d+):.*").find(input)?.let {
            return it.groupValues[1].toInt()
        }
    }

    private fun parseRuns(input: String): List<Map<Color, Int>> {
        return input.substringAfter(GAME_DELIMITOR)
            .trim()
            .split(ROUND_DELIMITOR)
            .map(::parseRounds)
    }

    private fun parseRounds(input: String): Map<Color, Int> {
        return input.trim().split(INNER_ROUND_DELIMITOR).fold(mutableMapOf<Color, Int>()) { acc, c ->
            Regex("(\\d+) (\\w+)").find(c)?.let { turn ->
                val (count, color) = turn.destructured
                acc[Color.valueOf(color.uppercase(Locale.getDefault()))] = count.toInt()
            }

            acc
        }.toMap()
    }

    override fun toString(): String {
        return "Game(id=$id, runs=$rounds)"
    }
}

fun part1(lines: List<String>): Int {
    return lines.map { Game(it) }
        .filter(Game::isValid)
        .sumOf(Game::getId)
}

fun part2(lines: List<String>): Int {
    return lines.map { Game(it) }.sumOf(Game::getFewest)
}
