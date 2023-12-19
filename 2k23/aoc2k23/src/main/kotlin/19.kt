package d19

fun main() {
    val (workflows, ratings) = input.raw("19.txt").split("\n\n").let {
        val workflows = it[0].split("\n")
            .map { line -> Workflow(line) }.associateBy { workflow -> workflow.id }

        val ratings = it[1].split("\n")
            .filter { line -> line.isNotBlank() }
            .map { rating -> Rating(rating) }

        workflows to ratings
    }

    println("Part 1: ${part1(workflows, ratings)}")
    println("Part 2: ${part2(workflows)}")
}

fun part1(workflows: Map<String, Workflow>, ratings: List<Rating>): Int {
    return ratings.filter { rating ->
        var res = workflows["in"]!!.run(rating)

        while (res != "A" && res != "R") {
            res = workflows[res]!!.run(rating)
        }

        res == "A"
    }.sumOf { it.sum() }
}

fun part2(workflows: Map<String, Workflow>): Long {
    return combinations(
        "in",
        workflows,
        mapOf(
            Rating.RatingKey.X to 1..4000,
            Rating.RatingKey.M to 1..4000,
            Rating.RatingKey.A to 1..4000,
            Rating.RatingKey.S to 1..4000
        )
    )
}

fun combinations(id: String, workflows: Map<String, Workflow>, ranges: Map<Rating.RatingKey, IntRange>): Long {
    val res: Long = when (id) {
        "R" -> 0L
        "A" -> {
            ranges.values.map { it.count().toLong() }.reduce(Long::times)
        }

        else -> {
            val newRanges = ranges.toMap().toMutableMap()

            workflows[id]!!.steps.sumOf { step ->
                when (step) {
                    is Workflow.SimpleStep -> {
                        combinations(step.target(), workflows, newRanges)
                    }

                    is Workflow.ConditionalStep -> {
                        when (step.operand) {
                            Workflow.ConditionalStep.Operand.LessThan -> {
                                val currentRange = newRanges[step.source]!!
                                newRanges[step.source] = currentRange.first..<step.value

                                combinations(step.target(), workflows, newRanges).also {
                                    newRanges[step.source] = step.value..currentRange.last
                                }
                            }

                            Workflow.ConditionalStep.Operand.MoreThan -> {
                                val currentRange = newRanges[step.source]!!
                                newRanges[step.source] = step.value + 1.. currentRange.last

                                combinations(step.target(), workflows, newRanges).also {
                                    newRanges[step.source] = currentRange.first..step.value
                                }
                            }
                        }

                    }

                    else -> {
                        throw IllegalStateException("oops")
                    }
                }
            }
        }
    }

    return res
}


class Rating(input: String) {
    private val ratingsRegex = Regex("""\w=(\d+)""")

    val values: Map<RatingKey, Int>

    init {
        val rates =
            ratingsRegex.findAll(input).map { rate -> rate.groupValues[1] }.map { number -> number.toInt() }.toList()

        values = mapOf(
            RatingKey.X to rates[0],
            RatingKey.M to rates[1],
            RatingKey.A to rates[2],
            RatingKey.S to rates[3]
        )
    }

    fun sum(): Int = values.values.sum()

    enum class RatingKey {
        X,
        M,
        A,
        S;

        companion object {
            fun fromString(input: String): RatingKey =
                when (input) {
                    "x" -> X
                    "m" -> M
                    "a" -> A
                    "s" -> S
                    else -> throw IllegalStateException("oops")
                }
        }
    }
}

class Workflow(input: String) {
    private val workflowRegex = Regex("""(\w+)\{(.*)}""")

    val steps: List<StepRunner>
    val id: String

    init {
        val matches = workflowRegex.find(input)
        id = matches!!.groupValues[1]
        steps = matches.groupValues[2].split(",").map { rawStep ->
            if (rawStep.contains(":")) {
                ConditionalStep(rawStep)
            } else {
                SimpleStep(rawStep)
            }
        }

    }

    fun run(rating: Rating): String {
        return steps.find { step -> step.predicate(rating) }!!.target()
    }

    interface StepRunner {
        fun target(): String
        fun predicate(rating: Rating): Boolean
    }

    class SimpleStep(private val target: String) : StepRunner {
        override fun target(): String = target

        override fun predicate(rating: Rating): Boolean = true
    }

    class ConditionalStep(input: String) : StepRunner {
        private val stepRegex = Regex("""([xmas])([<>])(\d+):(\w+)""")

        enum class Operand {
            LessThan,
            MoreThan;

            companion object {
                fun fromString(input: String): Operand =
                    when (input) {
                        ">" -> MoreThan
                        "<" -> LessThan
                        else -> throw IllegalStateException("oops")
                    }
            }
        }

        private val target: String
        val value: Int
        val source: Rating.RatingKey
        val operand: Operand

        init {
            val matches = stepRegex.find(input)

            source = Rating.RatingKey.fromString(matches!!.groupValues[1])
            operand = Operand.fromString(matches.groupValues[2])
            value = matches.groupValues[3].toInt()
            target = matches.groupValues.last()
        }

        override fun target(): String = target

        override fun predicate(rating: Rating): Boolean =
            when (operand) {
                Operand.LessThan -> rating.values[source]!! < value
                Operand.MoreThan -> rating.values[source]!! > value
            }
    }
}
