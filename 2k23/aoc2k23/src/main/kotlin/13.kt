package d13

import input.raw
import kotlin.math.min

fun main() {
    val input = parseInput(raw("13.txt"))

    println("Part 1: ${part1(input)}")
    println("Part 2: ${part2(input)}")
}

fun part1(notes: List<Note>): Int =
    notes.sumOf { it.findRowReflection(0) * 100 + it.findColumnReflection(0) }

fun part2(notes: List<Note>): Int =
    notes.sumOf { it.findRowReflection(1) * 100 + it.findColumnReflection(1) }

fun parseInput(input: String): List<Note> = input.split("\n\n").map { Note(it) }

class Note(input: String) {
    private val patterns = input.split("\n").filter { it.isNotBlank() }.map { it.toCharArray() }

    private val transposed = patterns[0].indices.map { i -> patterns.map { it[i] }.toCharArray() }

    fun findRowReflection(smudge: Int = 0): Int =
        (1..<patterns.size).find { patternIndex ->
            val differences = (0..<min(patterns.size - patternIndex, patternIndex)).sumOf { indexInPattern ->
                rowDiff(patternIndex - indexInPattern - 1, patternIndex + indexInPattern)
            }

            differences == smudge
        } ?: 0


    fun findColumnReflection(smudge: Int = 0): Int =
        (1..<transposed.size).find { patternIndex ->
            val differences = (0..<min(transposed.size - patternIndex, patternIndex)).sumOf { indexInPattern ->
                columnDiff(patternIndex - indexInPattern - 1, patternIndex + indexInPattern)
            }

            differences == smudge
        } ?: 0

    private fun rowDiff(indexA: Int, indexB: Int): Int =
        patterns[indexA].filterIndexed { index, c -> c != patterns[indexB][index] }.count()

    private fun columnDiff(indexA: Int, indexB: Int): Int =
        transposed[indexA].filterIndexed { index, c -> c != transposed[indexB][index] }.count()
}
