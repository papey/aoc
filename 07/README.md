# Day 5: Sunny with a Chance of Asteroids

## Subject

For example, suppose you want to try the phase setting sequence 3,1,2,4,0,
which would mean setting amplifier A to phase setting 3, amplifier B to
setting 1, C to 2, D to 4, and E to 0. Then, you could determine the output
signal that gets sent from amplifier E to the thrusters with the following
steps:

- Start the copy of the amplifier controller software that will run on
  amplifier A. At its first input instruction, provide it the amplifier's phase
  setting, 3. At its second input instruction, provide it the input signal, 0.
  After some calculations, it will use an output instruction to indicate the
  amplifier's output signal.
- Start the software for amplifier B. Provide it the phase setting (1) and then
  whatever output signal was produced from amplifier A. It will then produce a
  new output signal destined for amplifier C.
- Start the software for amplifier C, provide the phase setting (2) and the value from amplifier B, then collect its output signal. - Run amplifier D's software, provide the phase setting (4) and input
  value, and collect its output signal.
- Run amplifier E's software, provide the phase setting (0) and input value,
  and collect its output signal.

The final output signal from amplifier E would be sent to the thrusters.
However, this phase setting sequence may not have been the best one; another
sequence might have sent a higher signal to the thrusters.

Here are some example programs:

Max thruster signal `43210` (from phase setting sequence 4,3,2,1,0):

`3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0`

Max thruster signal `54321` (from phase setting sequence 0,1,2,3,4):

`3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0`

Max thruster signal `65210` (from phase setting sequence 1,0,4,3,2):

`3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0`

Try every combination of phase settings on the amplifiers. What is the highest signal that can be sent to the thrusters?

## Solution

Language used : [Golang](https://golang.org/)

### Run

    go run 7.go input/in 0
