#!/usr/bin/env python3

# imports
from collections import defaultdict
from string import ascii_uppercase

import networkx
import sys

# check if input arg is provided
if len(sys.argv) < 2:
    print("Santa is not happy, some of the arguments are missing")
    sys.exit(1)


# parse input
input = []
with open(sys.argv[1]) as f:
    for l in f.readlines():
        input.append(l.rstrip("\n"))

# init variables
grid = defaultdict()
graph = networkx.Graph()
width = len(input[0])
heigth = len(input)

# some usefull helpers
DIRECTIONS = [[0, -1], [1, 0], [0, 1], [-1, 0]]
START = "AA"
END = "ZZ"

# fill grid
for y in range(heigth):
    for x in range(width):
        # for each element, attach coordinates to current element
        grid[(x, y)] = input[y][x]


def visit(grid, x, y):
    """
    Check all valid adjacent positions
    """

    # store them in an array
    n = []

    # check all directions
    for d in DIRECTIONS:
        nx = x + d[0]
        ny = y + d[1]
        nv = grid[(nx, ny)]
        # if it's not an empty space or a wall
        if nv == "." or nv in ascii_uppercase:
            # add
            n.append(((nx, ny), nv))

    # return
    return n


portals = defaultdict(list)
start = (0, 0)
end = (0, 0)

# create graph by parsing grid
for y in range(1, heigth - 1):
    for x in range(1, width - 1):
        # get current value
        current = grid[(x, y)]

        # if it's a path, add it to graph
        if current == ".":
            graph.add_node((x, y))

            # if adjacent grid position is a path, add it to graph
            for (nx, ny), n in visit(grid, x, y):
                if n == ".":
                    graph.add_edge((x, y), (nx, ny))

        # if it's a portal name
        elif current in ascii_uppercase:
            # check adjacent gris positions
            neighbors = visit(grid, x, y)

            # if there is only two candidates, it's a gate letter and an entry point
            if len(neighbors) == 2:
                # if the first element is gate letter
                # destructure to get stuff into dedicated variables
                if neighbors[0][1] in ascii_uppercase:
                    (portal, letter), (entry, _) = neighbors
                else:
                    (entry, _), (portal, letter) = neighbors

                # ensure ER gate and ER gate are treated the same way
                key = "".join(sorted(current + letter))
                # append entry to current key value
                portals[key].append(entry)

                # get start and end position
                if key == START:
                    start = entry
                if key == END:
                    end = entry

# do not forget to connect portals and values
for connections in portals.values():
    # connect portals that have two connections
    if len(connections) == 2:
        graph.add_edge(connections[0], connections[1])

# compute result using networkx
print("Result, part 1 : %s" % (networkx.shortest_path_length(graph, start, end)))

# init variables
graph = networkx.Graph()
portals = defaultdict(list)
start = (0, 0)
end = (0, 0)

# deepness level, 42 is the awnser
deepness = 42

# create graph by parsing grid
for y in range(1, heigth - 1):
    for x in range(1, width - 1):
        # get current value
        current = grid[(x, y)]

        # if it's a path, add it to graph
        if current == ".":
            # one for each level
            for level in range(deepness):
                graph.add_node(((x, y), level))

            # if adjacent grid position is a path, add it to graph
            for (nx, ny), n in visit(grid, x, y):
                if n == ".":
                    # one node for each level
                    for level in range(deepness):
                        graph.add_edge(((x, y), level), ((nx, ny), level))

        # if it's a portal name
        elif current in ascii_uppercase:
            # check adjacent gris positions
            neighbors = visit(grid, x, y)

            # if there is only two candidates, it's a gate letter and an entry point
            if len(neighbors) == 2:
                # if the first element is gate letter
                # destructure to get stuff into dedicated variables
                if neighbors[0][1] in ascii_uppercase:
                    (portal, letter), (entry, _) = neighbors
                else:
                    (entry, _), (portal, letter) = neighbors

                # ensure ER gate and ER gate are treated the same way
                key = "".join(sorted(current + letter))
                # append entry to current key value
                portals[key].append(entry)

                # get start and end position
                if key == START:
                    start = entry
                if key == END:
                    end = entry

# do not forget to connect portals and values
for connections in portals.values():
    # connect portals that have two connections
    if len(connections) == 2:
        cx, cy = connections[0]
        # check it's outer or inner value
        if cx in [2, width - 3] or cy in [2, heigth - 3]:
            inn, out = connections
        else:
            out, inn = connections

        # for each level, connect outer with inner vice et versa
        for level in range(deepness - 1):
            graph.add_edge((inn, level + 1), (out, level))
            graph.add_edge((out, level), (inn, level + 1))


# compute result using networkx
print(
    "Result, part 2 : %s" % (networkx.shortest_path_length(graph, (start, 0), (end, 0)))
)
