import sys

ENTRY = "@"
WALL = "#"

DIRECTIONS = [(-1, 0), (1, 0), (0, -1), (0, 1)]

# check if input arg is provided
if len(sys.argv) < 2:
    print("Santa is not happy, some of the arguments are missing")
    sys.exit(1)

# read input
with open(sys.argv[1]) as file:
    grid = [e.rstrip("\n") for e in file.readlines()]


def reachable(grid, start, keys):
    """
    Get all reachable keys from current position
    """

    # array of position to process
    queue = [start]
    # tack seen position and distance from starting point
    distance = {start: 0}
    # dict of reachable keys containing distance and position
    rchbl = {}

    # while there is something in the queue
    while len(queue) > 0:
        # pop first element not last
        current = queue.pop()
        for nxt in compute_possible_positions(current, grid):
            case = grid[nxt[1]][nxt[0]]

            # if it's a wall or al already seen grid position
            if nxt in distance:
                continue

            # add position as seen with associated distance
            distance[nxt] = distance[current] + 1

            # if it's a door but we can't open it
            if isDoor(case) and case.lower() not in keys:
                continue

            # if it's a key and we don't have it
            if isKey(case) and case not in keys:
                rchbl[case] = nxt, distance[nxt]
            else:
                # if it's a default case, add it to queue
                queue.insert(0, nxt)

    # return all reachable keys
    return rchbl


def reachables(grid, start, keys):
    """
    Find reachable from all entrance
    """
    rchbl = {}

    for i in range(len(start)):
        for key, (point, dist) in reachable(grid, start[i], keys).items():
            rchbl[key] = point, dist, i

    return rchbl


def isDoor(value):
    """
    Check if a value is a door
    """
    return "A" <= value and value <= "Z"


def isKey(value):
    """
    Check if a value is a key
    """
    return "a" <= value and value <= "z"


def compute_possible_positions(start, grid):
    """
    Get all possible position that are in the grid and are not walls
    """
    possible = []

    for direct in DIRECTIONS:
        px, py = start[0] + direct[0], start[1] + direct[1]
        if 0 <= px < len(grid[0]) and 0 <= py < len(grid):
            if grid[py][px] != WALL:
                possible.append((px, py))

    return possible


def shortest(grid, start, keys):
    """
    Get shortest path all keys
    """

    # concat all getted keys into hashable
    getted = "".join(sorted(keys))
    # if distance for current position to key is known, return value
    if (start, getted) in paths:
        return paths[start, getted]
    # get all reachable keys
    rchbl = reachables(grid, start, keys)
    # if there is no reachable key it's done !
    if len(rchbl) == 0:
        paths[start, getted] = 0
        return 0
    # if keys
    else:
        # try shortest path for each new potential key
        tries = []
        for key, (point, dist, id) in rchbl.items():
            updated = tuple(
                [
                    point if identifier == id else pos
                    for identifier, pos in enumerate(start)
                ]
            )
            # append it to a list
            tries.append(dist + shortest(grid, updated, getted + key))

        # keep minimum distance
        res = min(tries)

    # save minimum distance between starting point to set of key
    paths[start, getted] = res
    return res


start = []
# find starting position
for y in range(len(grid)):
    for x in range(len(grid[0])):
        # if it's the entry, init start value
        if grid[y][x] == ENTRY:
            start.append((x, y))

# store found keys inside a dict
paths = {}
# get all reachable keys
print("Result, part 2 : %d" % shortest(grid, tuple(start), []))
