# Day 17: Set and Forget

Running the ASCII program on your Intcode computer will provide the current
view of the scaffolds. This is output, purely coincidentally, as ASCII code:
35 means #, 46 means ., 10 starts a new line of output below the current one,
and so on. (Within a line, characters are drawn left-to-right.)

In the camera output, # represents a scaffold and . represents open space.
The vacuum robot is visible as ^, v, <, or > depending on whether it is
facing up, down, left, or right respectively. When drawn like this, the
vacuum robot is always on a scaffold; if the vacuum robot ever walks off of a
scaffold and begins tumbling through space uncontrollably, it will instead be
visible as X.

In general, the scaffold forms a path, but it sometimes loops back onto
itself. For example, suppose you can see the following view from the cameras:

    ..#..........
    ..#..........
    #######...###
    #.#...#...#.#
    #############
    ..#...#...#..
    ..#####...^..

Here, the vacuum robot, ^ is facing up and sitting at one end of the scaffold
near the bottom-right of the image. The scaffold continues up, loops across
itself several times, and ends at the top-left of the image.

The first step is to calibrate the cameras by getting the alignment
parameters of some well-defined points. Locate all scaffold intersections;
for each, its alignment parameter is the distance between its left edge and
the left edge of the view multiplied by the distance between its top edge and
the top edge of the view. Here, the intersections from the above image are
marked O:

    ..#..........
    ..#..........
    ##O####...###
    #.#...#...#.#
    ##O###O###O##
    ..#...#...#..
    ..#####...^..

For these intersections:

- The top-left intersection is 2 units from the left of the image and 2 units
  from the top of the image, so its alignment parameter is 2 x 2 = 4.
- The bottom-left intersection is 2 units from the left and 4 units from the
  top, so its alignment parameter is 2 x 4 = 8.
- The bottom-middle intersection is 6 from the left and 4 from the top, so its
  alignment parameter is 24.
- The bottom-right intersection's alignment parameter is 40.

To calibrate the cameras, you need the sum of the alignment parameters. In the above example, this is 76.

Run your ASCII program. What is the sum of the alignment parameters for the scaffold intersections?

## Solution

Language used : [Golang](https://golang.org/)

### Run

    go run 17.go input/in
