package d04

import input.read

fun main() {
    println("Part 1: ${part1(read("04.txt"))}")
    println("Part 2: ${part2(read("04.txt"))}")
}

fun part1(lines: List<String>): Int {
    return lines.map(::Game).sumOf { game -> game.play() }
}

fun part2(lines: List<String>): Int {
    val games: List<Game> = lines.map(::Game)

    games.forEachIndexed { index, game ->
        (0..<game.win()).forEach{ n ->
            games[index + 1 + n].addCopies(game.getCopies())
        }
    }

    return games.sumOf() { game ->
        game.getCopies()
    }
}

class Game(line: String) {
    private val id: Int
    private val winningNumbers: List<Int>
    private val myNumbers: List<Int>
    private var copies: Int = 1

    init {
        line.split(":", limit = 2).let { gameParts ->
            id = Regex("Card\\s+(\\d+)").find(gameParts.first())!!.let { gameMatch ->
                gameMatch.groupValues[1].toInt()
            }

            gameParts[1].split("|", limit = 2).let { rawNumbers ->
                winningNumbers = rawNumbers[0].trim().split(Regex("\\s+")).map { it.toInt() }
                myNumbers = rawNumbers[1].trim().split(Regex("\\s+")).map { it.toInt() }
            }
        }
    }

    fun play(): Int {
        val winning = win()

        return if (winning > 0) {
            1 shl (winning - 1)
        } else {
            0
        }
    }

    fun win(): Int {
        return winningNumbers.intersect(myNumbers.toSet()).count()
    }

    fun addCopies(n: Int) {
        copies += n
    }

    fun getCopies(): Int {
        return copies
    }

    override fun toString(): String {
        return "Game $id: ${winningNumbers.joinToString(" ")}: ${myNumbers.joinToString(" ")}: $copies"
    }
}
