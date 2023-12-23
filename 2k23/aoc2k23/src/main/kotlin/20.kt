package d20

import input.read

fun main() {
    println("Part 1: ${part1(read("20.txt"))}")
    println("Part 2: ${part2(read("20.txt"))}")
}

fun part1(input: List<String>): Int {
    val modules = parseInput(input)
    val counter = Counter()

    repeat(1000) {
        press(modules, counter)
    }

    return counter.times()
}

fun part2(input: List<String>): Long {
    val modules = parseInput(input)
    val finder = Finder(modules)

    while (!finder.allFound()) {
        finder.handlePress()
        press(modules, finder)
    }

    return finder.lcm()
}


private fun parseInput(input: List<String>): Map<String, Module> {
    val modules = input.associate { line ->
        val type = line.first()
        val name = line.substring(1).substringBefore(" ")
        val destinations = line.substringAfter(" -> ").split(",").map { it.trim() }.filter { it.isNotEmpty() }

        when (type) {
            'b' -> "broadcaster" to Broadcaster(destinations)
            '%' -> name to FlipFlop(name, destinations)
            '&' -> name to Conjunction(name, destinations)
            else -> throw IllegalArgumentException("Unknown type: $type")
        }
    }

    val conjunctions = modules.values.filterIsInstance<Conjunction>().associateBy { it.name }

    modules.values.forEach { module ->
        module.destinations.forEach { destination ->
            conjunctions[destination]?.addSource(module.name)
        }
    }

    return modules
}

private fun press(modules: Map<String, Module>, pulsable: Pulsable) {
    val pulses = ArrayList<Pulse>().apply {
        add(Pulse(false, "button", "broadcaster"))
    }

    while (pulses.isNotEmpty()) {
        val pulse = pulses.removeFirst()
        pulsable.handlePulse(pulse)
        modules[pulse.destination]?.receive(pulse)?.forEach { pulses.add(it) }
    }
}

interface Pulsable {
    fun handlePulse(pulse: Pulse)
}

class Counter : Pulsable {
    private var low = 0
    private var high = 0
    override fun handlePulse(pulse: Pulse) {
        if (pulse.high) {
            high++
        } else {
            low++
        }
    }

    fun times(): Int = low * high
}

class Finder(modules: Map<String, Module>) : Pulsable {
    private var pressCount = 0L
    private val found = mutableSetOf<String>()
    private val watched: MutableMap<String, Long>

    init {
        val source = modules.values.first { "rx" in it.destinations }
        watched = modules.values.filter { source.name in it.destinations }
            .toMutableSet()
            .associate { it.name to 0L }
            .toMutableMap()

    }

    override fun handlePulse(pulse: Pulse) {
        if (pulse.high && pulse.source in watched) {
            found.add(pulse.source)
        }

        found.forEach { name ->
            if (watched.getValue(name) == 0L) {
                watched[name] = pressCount
            }
        }
    }

    fun handlePress() {
        pressCount++
    }

    fun lcm(): Long = watched.values.reduce { acc, i -> lcm(acc, i) }

    fun allFound(): Boolean = found.containsAll(watched.keys)

    private fun gcd(a: Long, b: Long): Long {
        return if (b == 0L) a else gcd(b, a % b)
    }

    private fun lcm(a: Long, b: Long): Long {
        return if (a == 0L || b == 0L) 0 else (a * b) / gcd(a, b)
    }
}


class Pulse(val high: Boolean, val source: String, val destination: String)

sealed class Module(val name: String, val destinations: List<String>) {
    abstract fun receive(pulse: Pulse): List<Pulse>

    fun send(high: Boolean): List<Pulse> = destinations.map { Pulse(high, name, it) }
}

private class Broadcaster(destinations: List<String>) : Module("broadcaster", destinations) {
    override fun receive(pulse: Pulse): List<Pulse> = send(pulse.high)
}

private class FlipFlop(name: String, destinations: List<String>) : Module(name, destinations) {
    private var on = false

    override fun receive(pulse: Pulse): List<Pulse> {
        if (pulse.high) {
            return emptyList()
        }

        on = !on

        return send(on)
    }
}

private class Conjunction(name: String, destinations: List<String>) : Module(name, destinations) {
    private val mem = mutableMapOf<String, Boolean>()

    fun addSource(source: String) {
        if (source !in mem) {
            mem[source] = false
        }
    }

    override fun receive(pulse: Pulse): List<Pulse> {
        mem[pulse.source] = pulse.high
        return send(!mem.values.all { it })
    }
}
