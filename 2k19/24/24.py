#!/usr/bin/env python

# imports
import sys
from copy import deepcopy

# part 1


def to_hashable(map):
    """ Compute a map to a hashbable
    """

    h = ""

    for e in map:
        for c in e:
            h += c

    return h


def biodiversity(map):
    """ Compute biodiversity of map
    """

    res = 0

    for y in range(len(map)):
        for x in range(len(map[0])):
            if map[y][x] == "#":
                res += 2 ** (y * len(map[0]) + x)

    return res


def adjacents(map, x, y):
    """ Check for adjacent bugs
    """

    bugs = 0

    # check all directions
    for d in DIRECTIONS:
        nx, ny = x + d[0], y + d[1]

        # ensure positions are in bound
        if 0 <= nx < len(map[0]) and 0 <= ny < len(map):
            # if it's a bug, add count it
            if map[ny][nx] == "#":
                bugs += 1

    return bugs


def increment(map):
    """ Go 1 minute further in map
    """

    # ensure deep copy
    next = deepcopy(map)

    # loop over all elements
    for y in range(len(map)):
        for x in range(len(map[0])):
            # check adjacent positions
            adj = adjacents(map, x, y)

            # default next char for current position is "." (no bugs)
            nxt = "."

            # if one of the two rules match infection
            if map[y][x] == "#":
                if adj == 1:
                    # next char is a bug
                    nxt = "#"
            else:
                if adj == 1 or adj == 2:
                    # next char is a bug
                    nxt = "#"

            # save next iteration in a temp value
            next[y][x] = nxt

    # return temp value to main routine
    return next


# check if input arg is provided
if len(sys.argv) < 2:
    print("Santa is not happy, some of the arguments are missing")
    sys.exit(1)


# parse input
input = []
with open(sys.argv[1]) as f:
    for l in f.readlines():
        input.append(list(l.rstrip()))

# some usefull helpers
DIRECTIONS = [[0, -1], [1, 0], [0, 1], [-1, 0]]

# memory of all states
states = {}

# init current with input
current = deepcopy(input)

while True:
    # if a states is found twice
    if to_hashable(current) in states:
        # print result and break
        print("Result, part 1 : %s" % states[to_hashable(current)])
        break

    # add state to memory
    states[to_hashable(current)] = biodiversity(current)
    # go one step further
    current = increment(current)

# part 2


def fields_allocation(MINUTES=200, size=5):
    """ Allocate an empty fields value with "." everywhere
    """

    return [
        [["." for _ in range(size)] for _ in range(size)]
        for _ in range(MINUTES * 2 + 3)
    ]


def evolve(fields, MINUTES, size=5):
    """ Go on step further in all levels
    """

    next = fields_allocation()

    # for all levels (execept last one and first one)
    for l in range(1, MINUTES * 2 + 2):
        # for all elements of each level
        for y in range(size):
            for x in range(size):
                # if it's center, continue
                if x == 2 and y == 2:
                    continue

                # get current value
                current = fields[l][y][x]
                # count neighbors for current value
                nghbs = neighbors(fields, l, x, y)

                # apply infection rules
                if current == "#":
                    if nghbs == 1:
                        next[l][y][x] = "#"

                else:
                    if nghbs == 2 or nghbs == 1:
                        next[l][y][x] = "#"

    # return all the levels
    return next


def neighbors(field, level, x, y):
    """ Check for adjacent bugs
    """
    bugs = 0

    # go in all possible directions
    for d in DIRECTIONS:
        current = "."

        # compute next coordinates
        nx, ny = x + d[0], y + d[1]

        # if it's center, go deeper
        if ny == 2 and nx == 2:
            bugs += deeper(field, level, x, y)

        # following the example bellow
        #
        #      |     |         |     |
        #   1  |  2  |    3    |  4  |  5
        #      |     |         |     |
        # -----+-----+---------+-----+-----
        #      |     |         |     |
        #   6  |  7  |    8    |  9  |  10
        #      |     |         |     |
        # -----+-----+---------+-----+-----
        #      |     |A|B|C|D|E|     |
        #      |     |-+-+-+-+-|     |
        #      |     |F|G|H|I|J|     |
        #      |     |-+-+-+-+-|     |
        #  11  | 12  |K|L|?|N|O|  14 |  15
        #      |     |-+-+-+-+-|     |
        #      |     |P|Q|R|S|T|     |
        #      |     |-+-+-+-+-|     |
        #      |     |U|V|W|X|Y|     |
        # -----+-----+---------+-----+-----
        #      |     |         |     |
        #  16  | 17  |    18   |  19 |  20
        #      |     |         |     |
        # -----+-----+---------+-----+-----
        #      |     |         |     |
        #  21  | 22  |    23   |  24 |  25
        #      |     |         |     |

        # top
        elif ny == -1:
            current = field[level + 1][1][2]

        # bottom
        elif ny == 5:
            current = field[level + 1][3][2]

        # left
        elif nx == -1:
            current = field[level + 1][2][1]

        # rigth
        elif nx == 5:
            current = field[level + 1][2][3]

        # current level
        else:
            current = field[level][ny][nx]

        # if it's a bug add it to counter
        if current == "#":
            bugs += 1

    return bugs


def deeper(field, level, x, y):

    # top
    if y == 1:
        return sum(field[level - 1][0][x] == "#" for x in range(5))

    # bottom
    if y == 3:
        return sum(field[level - 1][4][x] == "#" for x in range(5))

    # left
    if x == 1:
        return sum(field[level - 1][y][0] == "#" for y in range(5))

    # rigth
    if x == 3:
        return sum(field[level - 1][y][4] == "#" for y in range(5))


def countz(fields, DEEPNESS, size=5):
    """ Count bugs in all field levels
    """

    return sum(
        fields[l][y][x] == "#"
        for l in range(DEEPNESS)
        for y in range(size)
        for x in range(size)
    )


# initial input
map = deepcopy(input)

# iterations const
MINUTES = 200

# deepness
DEEPNESS = MINUTES * 2 + 3

# init fields
fields = fields_allocation(DEEPNESS)

# init first field
fields[MINUTES + 1] = deepcopy(map)

# for all minutes
for m in range(MINUTES):
    # evolve
    fields = evolve(fields, MINUTES)

print("Result, part 2 : %s" % countz(fields, DEEPNESS))
