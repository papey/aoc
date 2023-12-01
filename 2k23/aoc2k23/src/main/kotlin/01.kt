package d01

import input.read

fun main(args: Array<String>) {
    println("Part 1: ${part1(read("01.txt"))}")
    println("Part 2: ${part2(read("01.txt"))}")
}

fun part1(lines: List<String>): Int {
    return lines.map { line -> line.filter { it.isDigit() } }
        .map(::firstLastDigits)
        .sumOf { it.toInt() }
}

fun part2(lines: List<String>): Int {
    return lines.map(::replaceCharsWithDigits)
        .map { line -> line.filter { it.isDigit() } }
        .map(::firstLastDigits)
        .sumOf { it.toInt() }
}

fun firstLastDigits(line: String): String {
    val digits = line.toCharArray()
    return "${digits.first()}${digits.last()}"
}

fun replaceCharsWithDigits(line: String): String {
    val digitsMap = mapOf(
        "one" to 1,
        "two" to 2,
        "three" to 3,
        "four" to 4,
        "five" to 5,
        "six" to 6,
        "seven" to 7,
        "eight" to 8,
        "nine" to 9,
        "zero" to 0,
    )

    return digitsMap.entries.fold(line) { acc, entry ->
        val replace = "%s%s%s".format(entry.key, entry.value.toString(), entry.key)
        acc.replace(entry.key, replace)
    }
}
