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

	// run op codes
	buffer, err := run(memory, ini)
	if err != nil {
		return err
	}

	// verifyprint result
	err = verify(buffer)
	if err != nil {
		return err
	}

	// print last buffer element, the final result
	fmt.Println(buffer[len(buffer)-1])

	// no error
	return nil

}

// convert memory from string to an array of int
func memToInt(mem string) []int {

	// split data
	data := strings.Split(mem, ",")

	// allocate memory
	memory := make([]int, len(data))

	// convert all elements
	for index := 0; index < len(data); index++ {
		convert, err := strconv.Atoi(data[index])
		if err != nil {
			return nil
		}
		memory[index] = convert
	}

	// return converted memory
	return memory
}

// here goes all the complex logic
func run(mem []int, input int) (buffer []int, err error) {

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
			mem[mem[index+1]] = input
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
	debug := buffer[0:len(buffer)-1]

	// ensure they are all 0
	for _, v := range debug {
		if v != 0 {
			return errors.New("There is a non zero value in diagnostic tests")
			fmt.Println(debug)
		}
	}

	// looks good
	return nil

}