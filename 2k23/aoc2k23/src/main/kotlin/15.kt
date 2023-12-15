package d15

fun main() {
    println("Part 1: ${part1(input.read("15.txt"))}")
    println("Part 2: ${part2(input.read("15.txt"))}")
}

fun part1(input: List<String>): Int =
    input[0].split(",").sumOf { hash(it) }

fun part2(input: List<String>): Int {
    val boxes: MutableMap<Int, MutableMap<String, Int>> = mutableMapOf()

    input[0].split(",").forEach { elem ->
        if (elem.endsWith("-")) {
            val label = elem.replace("-", "")
            val hashed = hash(label)
            boxes.compute(hashed) { _, lenses -> lenses?.apply { remove(label) } ?: mutableMapOf() }
        } else {
            val (label, focalLength) = elem.split('=').let { Pair(it[0], it[1].toInt()) }
            val hashed = hash(label)
            boxes.compute(hashed) { _, lenses ->
                lenses?.apply { this[label] = focalLength } ?: mutableMapOf(label to focalLength)
            }
        }
    }

    return boxes.entries.sumOf { (box, slots) ->
        slots.entries.mapIndexed { slot, (_, focalLength) ->
            (box + 1) * (slot + 1) * focalLength
        }.sum()
    }
}

fun hash(input: String): Int =
    input.toCharArray().fold(0) { acc, c ->
        var next = acc
        next += c.code
        next *= 17
        next %= 256
        next
    }
