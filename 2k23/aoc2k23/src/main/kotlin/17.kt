package d17

import java.util.*

fun main() {
    println("Part 1: ${part1(input.read("17.txt"))}")
    println("Part 2: ${part2(input.read("17.txt"))}")
}

fun part1(input: List<String>): Int =
    FactoryCity(input).minimizeHeatLoss(1, 3)

fun part2(input: List<String>): Int =
    FactoryCity(input).minimizeHeatLoss(4, 10)

class FactoryCity(input: List<String>) {
    data class Point(val x: Int, val y: Int) {
        fun move(delta: Point): Point = Point(x + delta.x, y + delta.y)
    }

    enum class Direction(val point: Point) {
        North(Point(0, -1)),
        South(Point(0, 1)),
        East(Point(1, 0)),
        West(Point(-1, 0));

        private fun opposite(): Direction =
            when (this) {
                North -> South
                South -> North
                East -> West
                West -> East
            }

        fun directions(): List<Direction> =
            entries.filter { it != this.opposite() }
    }

    data class TravelState(val position: Point, val direction: Direction, val steps: Int)

    data class TravelHeatLoss(val state: TravelState, val heatLoss: Int) : Comparable<TravelHeatLoss> {
        override fun compareTo(other: TravelHeatLoss): Int {
            return heatLoss compareTo other.heatLoss
        }
    }

    private val map = input.map { row -> row.map { it.digitToInt() } }

    private val xMax = map.first().lastIndex
    private val yMax = map.lastIndex

    private val dest = Point(xMax, yMax)
    private val orig = Point(0, 0)

    private fun visit(point: Point): Int = map[point.y][point.x]

    fun minimizeHeatLoss(minSteps: Int, maxSteps: Int): Int {

        val heatLosses = mutableMapOf<TravelState, Int>().withDefault { Int.MAX_VALUE }
        val toVisit = PriorityQueue<TravelHeatLoss>()

        Direction.entries.forEach { dir ->
            val state = TravelState(orig, dir, 0)
            heatLosses[state] = 0
            toVisit.add(TravelHeatLoss(state, 0))
        }

        while (toVisit.isNotEmpty()) {
            val (currentState, heatLoss) = toVisit.poll();

            if (currentState.position == dest && currentState.steps >= minSteps) {
                return heatLoss
            }

            neighbors(currentState, minSteps, maxSteps).forEach { newState ->
                val newHeatLoss = heatLoss + visit(newState.position)

                if (newState !in heatLosses) {
                    heatLosses[newState] = newHeatLoss
                    toVisit.add(TravelHeatLoss(newState, newHeatLoss))
                }
            }
        }

        return -1
    }

    private fun neighbors(state: TravelState, minSteps: Int, maxSteps: Int): List<TravelState> {
        return state.direction.directions().filter { dir ->
            if (state.steps < minSteps) {
                dir == state.direction
            } else if (state.steps >= maxSteps) {
                dir != state.direction
            } else {
                true
            }
        }
            .map { dir ->
                TravelState(
                    state.position.move(dir.point),
                    dir,
                    if (dir == state.direction) state.steps + 1 else 1
                )
            }
            .filter { inBound(it.position) && it.steps <= maxSteps }
    }

    private fun inBound(point: Point): Boolean = point.x in 0..xMax && point.y in 0..yMax
}
