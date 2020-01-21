#!/usr/bin/env python3

import sys
import re
from copy import deepcopy
from math import gcd
from itertools import combinations

STEPS = 1000

# check if input arg is provided
if len(sys.argv) < 2:
    print("Santa is not happy, some of the arguments are missing")
    sys.exit(1)

positions = []
velocities = []

reg = re.compile(r"<x=(-?\d+), y=(-?\d+), z=(-?\d+)>")

# read input
with open(sys.argv[1]) as file:
    for l in file.readlines():
        # init positions
        positions.append([int(x) for x in list(reg.findall(l)[0])])

# init velocities to 0
[velocities.append([0] * 3) for _ in positions]

base = deepcopy(positions)


def lcm(a, b):
    """
    compute lcm (least common multiple)
    """
    return a * b // gcd(a, b)


def velocity(m1, m2, positions):
    """
    compute velocity between moons
    """

    v1 = [0] * 3
    v2 = [0] * 3

    for i in range(3):
        res = compare(positions[m1][i], positions[m2][i])
        v1[i] = -res
        v2[i] = res

    return v1, v2


def compare(c1, c2):
    return (c1 > c2) - (c1 < c2)


def gravity(positions, velocities):
    """
    compute velocities for each moon combinations
    """
    # for every combinations of moons
    for m1, m2 in combinations(range(len(positions)), 2):
        v1, v2 = velocity(m1, m2, positions)
        for i in range(len(v1)):
            velocities[m1][i] += v1[i]
            velocities[m2][i] += v2[i]


def update(positions, velocities):
    """
    update position using velocities
    """

    for i in range(len(positions)):
        positions[i] = move(positions[i], velocities[i])


def move(moon, vel):
    """
    apply velocity to related moon
    """

    for i in range(len(moon)):
        moon[i] += vel[i]

    return moon


def nrj(pos, vel):
    """
    compute energy for given moon
    """
    return sum([abs(e) for e in pos]) * sum([abs(e) for e in vel])


# run all desired steps
for _ in range(STEPS):
    gravity(positions, velocities)
    update(positions, velocities)

print(
    "Result, part 1 : %d"
    % (sum((nrj(positions[i], velocities[i]) for i in range(len(positions)))))
)

# each axis are independents
steps = []

# copy base positions
positions = deepcopy(base)

# axis selector
axis = 0

# find each axis repetition independently
while len(steps) < 3:
    # ticks equals 0
    ticks = 0

    # use this as current values, for selected axis
    current_positions = [p[axis] for p in positions]
    current_velocities = [0 for _ in positions]

    # use this as a base values, for selected axis
    from_positions = [p[axis] for p in positions]
    from_velocities = [0 for _ in positions]

    # tick and break
    while True:
        # do as before but on one axis only
        # gravity
        for m1, m2 in combinations(range(len(positions)), 2):
            vel = compare(current_positions[m1], current_positions[m2])
            current_velocities[m1] -= vel
            current_velocities[m2] += vel

        # update
        for index, _ in enumerate(velocities):
            current_positions[index] += current_velocities[index]

        # increment steps for this axis
        ticks += 1

        # check if current positions and velocities are equals to original positions and velocities
        if (
            current_positions == from_positions
            and current_velocities == from_velocities
        ):
            # add related axis value to steps array
            steps.append(ticks)
            # find next axis value
            axis += 1
            break

# copute lcm for all values as tmp = lcm(x, y) then lcm(tmp, z)
total = lcm(lcm(steps[0], steps[1]), steps[2])

print("Result, part 2 : %d" % total)
