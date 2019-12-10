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
	if len(os.Args) < 2 {
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
	err = exec(strings.TrimSpace(string(mem)))
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

}

// exec contains main program logic
func exec(mem string) error {

	// translate readed memory from strings to ints
	memory := memToInt(mem)
	if memory == nil {
		return errors.New("Error converting memory to ints")
	}

	// array storing results
	results := make([]int, 0)

	// compute all phases permutations
	phases := permutations([]int{5, 6, 7, 8, 9})
	// run on all permutations
	for _, phase := range phases {

		// run phase on current selected phase
		res := amplifiers(memory, phase)

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

// amplifiers runs all amplifiers in //, thanks reddit for help and hints
func amplifiers(mem []int, phase []int) int {
	// used to count finished run, avoid wait group, we love channels here
	finished := make(chan bool)

	// channels for all amplifiers
	e2a := make(chan int, 1) // limit final output to 1 element
	a2b := make(chan int)
	b2c := make(chan int)
	c2d := make(chan int)
	d2e := make(chan int)

	// start amplifiers in parallel.
	go run(mem, e2a, a2b, finished)
	go run(mem, a2b, b2c, finished)
	go run(mem, b2c, c2d, finished)
	go run(mem, c2d, d2e, finished)
	go run(mem, d2e, e2a, finished)

	// Provide phase settings.
	e2a <- phase[0]
	a2b <- phase[1]
	b2c <- phase[2]
	c2d <- phase[3]
	d2e <- phase[4]

	// Send initial input signal.
	e2a <- 0

	// all runs needs a finished state
	for i := 0; i < 5; i++ {
		<-finished
	}

	// return final result
	return <-e2a
}

// run updated to run in // using channels
func run(codes []int, in <-chan int, out chan<- int, finished chan<- bool) {
	// WAS A CAUSE OF SHITTY ERROR, COPY IS NEEDED
	mem := make([]int, len(codes))
	copy(mem, codes)

	index := 0
	for {
		ops := padOp(mem[index])

		switch ops[0] {

		case 1: // +
			p1 := getParam(mem, ops[1], index+1)
			p2 := getParam(mem, ops[2], index+2)
			mem[mem[index+3]] = p1 + p2
			index += 4

		case 2: // *
			p1 := getParam(mem, ops[1], index+1)
			p2 := getParam(mem, ops[2], index+2)
			mem[mem[index+3]] = p1 * p2
			index += 4

		case 3: // in
			mem[mem[index+1]] = <-in
			index += 2

		case 4: // out
			out <- mem[mem[index+1]]
			index += 2

		case 5: // jump-if-true
			p1 := getParam(mem, ops[1], index+1)
			p2 := getParam(mem, ops[2], index+2)
			if p1 != 0 {
				index = p2
			} else {
				index += 3
			}

		case 6: // jump-if-false
			p1 := getParam(mem, ops[1], index+1)
			p2 := getParam(mem, ops[2], index+2)
			if p1 == 0 {
				index = p2
			} else {
				index += 3
			}

		case 7: // <
			p1 := getParam(mem, ops[1], index+1)
			p2 := getParam(mem, ops[2], index+2)
			if p1 < p2 {
				mem[mem[index+3]] = 1
			} else {
				mem[mem[index+3]] = 0
			}
			index += 4

		case 8: // ==
			p1 := getParam(mem, ops[1], index+1)
			p2 := getParam(mem, ops[2], index+2)
			if p1 == p2 {
				mem[mem[index+3]] = 1
			} else {
				mem[mem[index+3]] = 0
			}
			index += 4

		case 99: // finish
			finished <- true
			return

		default:
			panic("Should not reach this state")
		}
	}
}
