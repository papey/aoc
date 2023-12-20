package d18

import input.read
import kotlin.math.absoluteValue

fun main() {
    println("Part 1: ${part1(read("18.txt"))}")
    println("Part 2: ${part2(read("18.txt"))}")
}

fun part1(input: List<String>): Long {
    val instructions = input.map { line ->
        line.split(" ").let {
            val dir = when(it[0]) {
                "R" -> Direction.Right
                "U" -> Direction.Up
                "L" -> Direction.Left
                "D" -> Direction.Down
                else -> throw IllegalStateException("oops")
            }

            Instruction(dir, it[1].toLong())
        }

    }

    return area(instructions)
}

fun part2(input: List<String>): Long {
    val regex = Regex("""\(#([0-9A-Fa-f]{5})(\d)\)""")

    val instructions = input.map { line ->
        val values = regex.find(line)!!.groupValues

        val quantity = values[1].toLong(16)
        val dir = when(values[2]) {
            "0" -> Direction.Right
            "1" -> Direction.Down
            "2" -> Direction.Left
            "3" -> Direction.Up
            else -> throw IllegalStateException("oops")
        }

        Instruction(dir, quantity)
    }

    return area(instructions)
}

fun area(instructions: List<Instruction>): Long =
    instructions.fold(State(0, 0, Point(0, 0))) { acc, inst ->
        val edge = acc.pos.move(inst)
        val area = acc.area + (acc.pos.x * edge.y - edge.x * acc.pos.y)
        val perimeter = acc.perimeter + (edge.x - acc.pos.x).absoluteValue + (edge.y - acc.pos.y).absoluteValue
        State(area, perimeter, edge)
    }.let { (area, perimeter, _) ->
        (area.absoluteValue + perimeter) / 2 + 1
    }

data class State (val area: Long, val perimeter: Long, val pos: Point)

enum class Direction {
   Up,
   Down,
   Left,
   Right;
}

data class Instruction(val dir: Direction, val quantity: Long)

data class Point(val x: Long, val y: Long) {
    fun move(inst: Instruction): Point =
        when(inst.dir) {
            Direction.Up -> Point(x - inst.quantity, y)
            Direction.Down -> Point(x + inst.quantity, y)
            Direction.Right -> Point(x, y + inst.quantity)
            Direction.Left -> Point(x, y - inst.quantity)
        }
}
