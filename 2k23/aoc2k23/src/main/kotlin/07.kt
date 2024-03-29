package d07

import input.read

fun main() {
    println("Part 1: ${part1(read("07.txt"))}")
    println("Part 2: ${part2(read("07.txt"))}")
}

class Hand(line: String) {
    // A, K, Q, J, T, 9, 8, 7, 6, 5, 4, 3, or 2
    enum class CardP1(val value: Char) {
        TWO('2'),
        THREE('3'),
        FOUR('4'),
        FIVE('5'),
        SIX('6'),
        SEVEN('7'),
        EIGHT('8'),
        NINE('9'),
        T('T'),
        J('J'),
        Q('Q'),
        K('K'),
        A('A');

        companion object {
            fun fromChar(value: Char): CardP1? {
                return entries.find { it.value == value }
            }
        }
    }

    // A, K, Q, T, 9, 8, 7, 6, 5, 4, 3, 2, or J
    enum class CardP2(val value: Char) {
        J('J'),
        TWO('2'),
        THREE('3'),
        FOUR('4'),
        FIVE('5'),
        SIX('6'),
        SEVEN('7'),
        EIGHT('8'),
        NINE('9'),
        T('T'),
        Q('Q'),
        K('K'),
        A('A');

        companion object {
            fun fromChar(value: Char): CardP2? {
                return entries.find { it.value == value }
            }
        }
    }

    enum class Type {
        HighCard,
        OnePair,
        TwoPair,
        ThreeOfKind,
        FullHouse,
        FourOfKind,
        FiveOfKind;

        companion object {
            private fun computeType(top1Count: Int, top2Count: Int): Type {
                return when (top1Count) {
                    5 -> FiveOfKind
                    4 -> FourOfKind
                    3 -> {
                        if (top2Count == 2) {
                            FullHouse
                        } else {
                            ThreeOfKind
                        }
                    }

                    2 -> {
                        if (top2Count == 2) {
                            TwoPair
                        } else {
                            OnePair
                        }
                    }

                    else -> HighCard
                }

            }

            fun fromHandP1(hand: List<CardP1>): Type {
                val byValue = hand.groupBy { it.value }.mapValues { it.value.size }
                val counts = byValue.values.sortedByDescending { it }

                return computeType(counts[0], counts.getOrElse(1) { _ -> 0 })
            }

            fun fromHandP2(hand: List<CardP2>): Type {
                val byValue = hand.groupBy { it.value }.mapValues { it.value.size }
                val counts = byValue.filter { it.key != CardP2.J.value }.values.sortedByDescending { it }
                val jokers = hand.count { it.value == CardP2.J.value }

                if (jokers == 5) {
                    return Type.FiveOfKind
                }

                return computeType(counts[0] + jokers, counts.getOrElse(1) { _ -> 0 })
            }
        }
    }


    val cardsP1: List<CardP1>
    val cardsP2: List<CardP2>

    val typeP1: Type
    val typeP2: Type

    val bid: Int

    init {
        cardsP1 = line.split(" ").first().toCharArray().map { CardP1.fromChar(it)!! }
        cardsP2 = line.split(" ").first().toCharArray().map { CardP2.fromChar(it)!! }
        typeP1 = Type.fromHandP1(cardsP1)
        typeP2 = Type.fromHandP2(cardsP2)
        bid = line.split(" ").drop(1).first().toInt()
    }

    companion object {
        fun comparatorP1(): Comparator<Hand> {
            return Comparator { hand1, hand2 ->
                if (hand1.typeP1 != hand2.typeP1) {
                    hand1.typeP1.compareTo(hand2.typeP1)
                } else {
                    val ret = hand1.cardsP1.zip(hand2.cardsP1).find { s -> s.first != s.second }!!
                    ret.first.compareTo(ret.second)
                }
            }
        }

        fun comparatorP2(): Comparator<Hand> {
            return Comparator { hand1, hand2 ->
                if (hand1.typeP2 != hand2.typeP2) {
                    hand1.typeP2.compareTo(hand2.typeP2)
                } else {
                    val ret = hand1.cardsP2.zip(hand2.cardsP2).find { s -> s.first != s.second }!!
                    ret.first.compareTo(ret.second)
                }
            }
        }
    }
}

fun part1(lines: List<String>): Int =
    lines.map(::Hand).sortedWith(Hand.comparatorP1()).mapIndexed { index, hand -> (index + 1) * hand.bid }.sum()

fun part2(lines: List<String>): Int =
    lines.map(::Hand).sortedWith(Hand.comparatorP2()).mapIndexed { index, hand -> (index + 1) * hand.bid }.sum()
