# Day 2: 1202 Program Alarm

## Subject

An Intcode program is a list of integers separated by commas (like
1,0,0,3,99). To run one, start by looking at the first integer (called
position 0). Here, you will find an opcode - either 1, 2, or 99. The opcode
indicates what to do; for example, 99 means that the program is finished and
should immediately halt. Encountering an unknown opcode means something went
wrong.

Opcode 1 adds together numbers read from two positions and stores the result
in a third position. The three integers immediately after the opcode tell you
these three positions - the first two indicate the positions from which you
should read the input values, and the third indicates the position at which
the output should be stored.

For example, if your Intcode computer encounters 1,10,20,30, it should read
the values at positions 10 and 20, add those values, and then overwrite the
value at position 30 with their sum.

Opcode 2 works exactly like opcode 1, except it multiplies the two inputs
instead of adding them. Again, the three integers after the opcode indicate
where the inputs and outputs are, not their values.

Once you're done processing an opcode, move to the next one by stepping
forward 4 positions.

## Solution

Language used : [Crystal](https://crystal-lang.org/)

### Run

    crystal run 2.cr -- input/in
