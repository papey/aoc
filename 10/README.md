# Day 10 :

## Subject

For example, consider the following map:

    .#..#
    .....
    #####
    ....#
    ...##

The best location for a new monitoring station on this map is the highlighted
asteroid at 3,4 because it can detect 8 asteroids, more than any other
location. (The only asteroid it cannot detect is the one at 1,0; its view of
this asteroid is blocked by the asteroid at 2,2.) All other asteroids are
worse locations; they can detect 7 or fewer other asteroids. Here is the
number of other asteroids a monitoring station on each asteroid could detect:

    .7..7
    .....
    67775
    ....7
    ...87

## Solution

Language used : [Crystal](https://crystal-lang.org/)

### Run

    crystal run 10.cr -- input/in
