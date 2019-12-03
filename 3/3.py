#!/usr/bin/env python3

# impoooooorts
import sys

# Check args
if len(sys.argv) != 2:
    print("Santa if not happy, some of the arguments are missing")
    sys.exit(1)

# Open and read file
with open(sys.argv[1]) as f:
    # get the cable w and x paths
    w, x = f.read().splitlines()


# Format data inside arrays
w = w.split(",")
x = x.split(",")

# Translate a move to a computable direction
delta = {"R": (0, 1), "L": (0, -1), "U": (1, 1), "D": (1, -1)}


def compute_points(move, pos, steps, path):
    """
    compute both position and steps for a point in the grid
    """

    # split move code, first part is direction, second part is distance
    direc, dist = move[0], int(move[1:])
    # translate this direction to real usable values using delta directory
    index, val = delta[direc]

    # loop over distance
    for _ in range(dist):
        # compute position
        pos[index] += val
        # add step
        steps += 1
        # add a new point at position pos inside path
        path[tuple(pos)] = steps

    # return steps in order to keep to reused it
    return steps


def compute_wire(w):
    """
    compute both position and steps for a wire (or a set of points)
    """

    # position in the grid, updated as we run the wire
    pos = [0, 0]
    # dict containing point position and associated steps to reach it
    path = {}
    # steps counter for current wire
    steps = 0
    # for each move in the wire
    for move in w:
        # compute point, add it to path, return updated steps
        steps = compute_points(move, pos, steps, path)

    # once we reach the end of the wire, return directory containing wire data
    return path


# compute wire data for each wire
wp = compute_wire(w)
xp = compute_wire(x)

# Find intersections between wires
intersect = set(wp.keys()) & set(xp.keys())

# minimal distance, juste use points position
res = min(abs(a)+abs(b) for (a, b) in intersect)

print("Result (1) : %i" % res)

# path distance, use steps instead of positions
res = min(abs(wp[ints])+abs(xp[ints]) for ints in intersect)

print("Result (2) : %i" % res)
