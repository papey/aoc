package main

import (
	"errors"
	"fmt"
	"io/ioutil"
	"os"
	"strconv"
	"strings"
)

// main
func main() {

	// check args
	if len(os.Args) < 3 {
		fmt.Println("Santa is not happy, some of the arguments are missing")
		os.Exit(1)
	}

	// read data
	mem, err := ioutil.ReadFile(os.Args[1])
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	// compute
	err = exec(strings.TrimSpace(string(mem)), os.Args[2])
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

}

// exec contains main program logic
func exec(mem string, init string) error {

	// translate readed memory from strings to ints
	memory := memToInt(mem)
	if memory == nil {
		return errors.New("Error converting memory to ints")
	}

	// translate init value from string to int
	ini, err := strconv.Atoi(init)
	if err != nil {
		return errors.New("Init is not a number")
	}

	// array storing results
	results := make([]int, 0)

	// compute all phases permutations
	phases := permutations([]int{0, 1, 2, 3, 4})
	// run on all permutations
	for _, phase := range phases {

		// run phase on current selected phase
		res, err := runPhases(phase, memory, ini)
		if err != nil {
			return errors.New("Error runnning program on phases")
		}

		// add result to array
		results = append(results, res)
	}

	fmt.Println(find(results))

	// no error
	return nil

}

// find will find the maximum value inside an array
func find(data []int) int {
	max := data[0]

	for _, elem := range data {
		if elem >= max {
			max = elem
		}
	}

	return max

}

// permutations will compute all possible permutation for a given array
func permutations(from []int) (result [][]int) {

	if len(from) == 1 {
		// append last elem
		result = append(result, from)
		return
	}

	for i, cur := range from {
		// extract moving part inside current array
		remain := make([]int, 0, len(from)-1)
		// get first part
		remain = append(remain, from[:i]...)
		// get last part
		remain = append(remain, from[i+1:]...)
		// regenerate for all remaining data
		for _, path := range permutations(remain) {
			// add current permutation
			result = append(result, append(path, cur))
		}
	}

	return
}

// run_phases will run the program on all phases
func runPhases(phases []int, memory []int, ini int) (res int, err error) {

	// copy memory localy, do not mutate the original one
	mem := memory

	// run_amplifiers
	for _, elem := range phases {

		// run op codes
		buffer, err := run(mem, elem, ini)
		if err != nil {
			return 0, err
		}

		// verify print result
		err = verify(buffer)
		if err != nil {
			return 0, err
		}

		// print last buffer element, the final result
		ini = buffer[len(buffer)-1]
	}

	return ini, nil

}

// convert memory from string to an array of int
func memToInt(mem string) []int {

	// split data
	data := strings.Split(mem, ",")

	// allocate memory
	memory := make([]int, len(data))

	// convert all elements
	for index, val := range data {
		convert, err := strconv.Atoi(val)
		if err != nil {
			return nil
		}
		memory[index] = convert
	}

	// return converted memory
	return memory
}

// here goes all the complex logic
func run(mem []int, phase int, input int) (buffer []int, err error) {

	// do not output directly to stdout, buffer is used to auto verify using diagnostic tests
	buffer = make([]int, 0)

	// start at 0, what else ?
	index := 0

	// infinite loop
	for {

		// get ops
		ops := padOp(mem[index])

		// exit is 99 is found
		if ops[0] == 99 {
			return buffer, nil
		}

		// handle all op code cases
		switch ops[0] {
		case 1:
			// +
			p1 := getParam(mem, ops[1], index+1)
			p2 := getParam(mem, ops[2], index+2)
			mem[mem[index+3]] = p1 + p2
			// OP, P1, P2, OUT = 4
			index += 4
			break
		case 2:
			// *
			p1 := getParam(mem, ops[1], index+1)
			p2 := getParam(mem, ops[2], index+2)
			mem[mem[index+3]] = p1 * p2
			// OP, P1, P2, OUT = 4
			index += 4
			break
		case 3:
			// put input
			if index == 0 {
				// if it's the first run, use the phase
				mem[mem[index+1]] = phase
			} else {
				// else, use the input
				mem[mem[index+1]] = input
			}
			// OP, ADDR = 2
			index += 2
			break
		case 4:
			// add value to buffer
			buffer = append(buffer, getParam(mem, ops[1], index+1))
			// OP, MODE = 2
			index += 2
			break
		case 5:
			// jump-if-true
			p1 := getParam(mem, ops[1], index+1)
			if p1 != 0 {
				index = getParam(mem, ops[2], index+2)
			} else {
				index += 3
			}
			break
		case 6:
			// jump-if-false
			p1 := getParam(mem, ops[1], index+1)
			if p1 == 0 {
				index = getParam(mem, ops[2], index+2)
			} else {
				index += 3
			}
			break
		case 7:
			// less
			p1 := getParam(mem, ops[1], index+1)
			p2 := getParam(mem, ops[2], index+2)
			if p1 < p2 {
				mem[mem[index+3]] = 1

			} else {
				mem[mem[index+3]] = 0
			}
			index += 4
			break
		case 8:
			// equal
			p1 := getParam(mem, ops[1], index+1)
			p2 := getParam(mem, ops[2], index+2)
			if p1 == p2 {
				mem[mem[index+3]] = 1

			} else {
				mem[mem[index+3]] = 0
			}
			index += 4
			break

		}
	}

}

// get an OP code, pad it using 0, split it to get op code, mode, and parameters
func padOp(op int) []int {

	ops := make([]int, 4)

	// pad op code by adding 0 up front
	padded := fmt.Sprintf("%05d", op)

	// opcode
	ops[0], _ = strconv.Atoi(string(padded[3:5]))
	// mode 1
	ops[1], _ = strconv.Atoi(string(padded[2]))
	// mode 2
	ops[2], _ = strconv.Atoi(string(padded[1]))
	// mode 3
	ops[3], _ = strconv.Atoi(string(padded[0]))

	return ops

}

// get param at index using modes
func getParam(mem []int, mode int, index int) int {

	// at addr mode
	if mode == 0 {
		return mem[mem[index]]
	}

	// direct mode
	if mode == 1 {
		return mem[index]
	}

	// If something goes wrong, do not fail, but : 💥
	fmt.Println("💥 Error, unsupported mode, abort mission 💥")

	return 0
}

// auto verify result with diagnostic tests
func verify(buffer []int) error {

	// get all the diagnostic tests
	debug := buffer[0 : len(buffer)-1]

	// ensure they are all 0
	for _, v := range debug {
		if v != 0 {
			return errors.New("There is a non zero value in diagnostic tests")
		}
	}

	// looks good
	return nil

}
