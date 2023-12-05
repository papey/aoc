package d05

import input.raw
import java.util.concurrent.atomic.AtomicLong
import kotlin.math.min
import kotlin.streams.asStream

fun main() {
    println("Part 1: ${part1(raw("05.txt").trim())}")
    println("Part 2: ${part2(raw("05.txt").trim())}")
}

fun part1(input: String): Long {
    val (seeds, maps) = parse(input)

    return seeds.minOf { seed -> findLocation(maps, seed) }
}


fun part2(input: String): Long {
    val (seeds, maps) = parse(input)
    val seedRanges = seeds.chunked(2).map { (start, range) -> start..<(start + range) }
    val result = AtomicLong(Long.MAX_VALUE)

    for (range in seedRanges) {
        range.asSequence().asStream().parallel().forEach { seed ->
            result.getAndAccumulate(findLocation(maps, seed), ::min)
        }
    }

    return result.get()
}

private fun findLocation(maps: List<List<MapRange>>, seed: Long) =
    maps.fold(seed) { s, map ->
        val match = map.find { s >= it.srcStart && s <= it.srcStart + it.length }?.let {
            it.dstStart + (s - it.srcStart)
        }

        match ?: s
    }

private fun parse(input: String): Pair<List<Long>, List<List<MapRange>>> {
    val parts = input.split("\n\n")
    val seeds = parts[0].replace("seeds: ", "").split(" ").map { it.toLong() }

    val maps = parts.drop(1).map { map ->
        map.split("\n").drop(1).map { line ->
            val values = line.split(" ").filter { it.isNotBlank() }.map { it.toLong() }
            MapRange(values[1], values[0], values[2])
        }
    }

    return Pair(seeds, maps)
}

class MapRange(val srcStart: Long, val dstStart: Long, val length: Long) {}
