# Day 12: The N-Body Problem

## Subject

The space near Jupiter is not a very safe place; you need to be careful of a
big distracting red spot, extreme radiation, and a whole lot of moons
swirling around. You decide to start by tracking the four largest moons: Io,
Europa, Ganymede, and Callisto.

After a brief scan, you calculate the position of each moon (your puzzle
input). You just need to simulate their motion so you can avoid them.

Each moon has a 3-dimensional position (x, y, and z) and a 3-dimensional
velocity. The position of each moon is given in your scan; the x, y, and z
velocity of each moon starts at 0.

Simulate the motion of the moons in time steps. Within each time step, first
update the velocity of every moon by applying gravity. Then, once all moons'
velocities have been updated, update the position of every moon by applying
velocity. Time progresses by one step once all of the positions are updated.

To apply gravity, consider every pair of moons. On each axis (x, y, and z),
the velocity of each moon changes by exactly +1 or -1 to pull the moons
together. For example, if Ganymede has an x position of 3, and Callisto has a
x position of 5, then Ganymede's x velocity changes by +1 (because 5 > 3) and
Callisto's x velocity changes by -1 (because 3 < 5). However, if the
positions on a given axis are the same, the velocity on that axis does not
change for that pair of moons.

Once all gravity has been applied, apply velocity: simply add the velocity of
each moon to its own position. For example, if Europa has a position of x=1,
y=2, z=3 and a velocity of x=-2, y=0,z=3, then its new position would be
x=-1, y=2, z=6. This process does not modify the velocity of any moon.

## Solution

Language used : [Python](https://www.python.org/)

### Run

    python 3.py input/in
