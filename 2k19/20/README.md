# Day 20: Donut Maze

## Subject

This map of the maze shows solid walls (#) and open passages (.). Every maze
on Pluto has a start (the open tile next to AA) and an end (the open tile
next to ZZ). Mazes on Pluto also have portals; this maze has three pairs of
portals: BC, DE, and FG. When on an open tile next to one of these labels, a
single step can take you to the other tile with the same label. (You can only
walk on . tiles; labels and empty space are not traversable.)

One path through the maze doesn't require any portals. Starting at AA, you
could go down 1, right 8, down 12, left 4, and down 1 to reach ZZ, a total of
26 steps.

However, there is a shorter path: You could walk from AA to the inner BC
portal (4 steps), warp to the outer BC portal (1 step), walk to the inner DE
(6 steps), warp to the outer DE (1 step), walk to the outer FG (4 steps),
warp to the inner FG (1 step), and finally walk to ZZ (6 steps). In total,
this is only 23 steps.

Here is a larger example:

                    A
                    A
    #################.#############
    #.#...#...................#.#.#
    #.#.#.###.###.###.#########.#.#
    #.#.#.......#...#.....#.#.#...#
    #.#########.###.#####.#.#.###.#
    #.............#.#.....#.......#
    ###.###########.###.#####.#.#.#
    #.....#        A   C    #.#.#.#
    #######        S   P    #####.#
    #.#...#                 #......VT
    #.#.#.#                 #.#####
    #...#.#               YN....#.#
    #.###.#                 #####.#
    DI....#.#                 #.....#
    #####.#                 #.###.#
    ZZ......#               QG....#..AS
    ###.###                 #######
    JO..#.#.#                 #.....#
    #.#.#.#                 ###.#.#
    #...#..DI             BU....#..LF
    #####.#                 #.#####
    YN......#               VT..#....QG
    #.###.#                 #.###.#
    #.#...#                 #.....#
    ###.###    J L     J    #.#.###
    #.....#    O F     P    #.#...#
    #.###.#####.#.#####.#####.###.#
    #...#.#.#...#.....#.....#.#...#
    #.#####.###.###.#.#.#########.#
    #...#.#.....#...#.#.#.#.....#.#
    #.###.#####.###.###.#.#.#######
    #.#.........#...#.............#
    #########.###.###.#############
            B   J   C
            U   P   P

Here, AA has no direct path to ZZ, but it does connect to AS and CP. By
passing through AS, QG, BU, and JO, you can reach ZZ in 58 steps.

In your maze, how many steps does it take to get from the open tile marked AA
to the open tile marked ZZ ?

## Solution

Language used : [Python](https://www.python.org/)

### Dependencies

- [Networkx](https://networkx.github.io/)

### Run

    python3 20.py input/in
