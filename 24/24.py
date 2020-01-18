#!/usr/bin/env python

# imports
import sys
from copy import deepcopy


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
