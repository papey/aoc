package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"strconv"
	"strings"
)

func main() {
	// check args
	if len(os.Args) < 2 {
		fmt.Println("Santa is not happy, some of the arguments are missing")
		os.Exit(1)
	}

	// read data
	input, err := ioutil.ReadFile(os.Args[1])
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	// get all codes from input
	codes := strings.Split(strings.TrimSpace(string(input)), ",")

	// intcode computer memory
	mem := map[int]int64{}

	// use a map since memory can be discontinue
	for i, c := range codes {
		// into map
		mem[i], _ = strconv.ParseInt(c, 10, 0)
	}

	// input and output channels
	in := make(chan int64, 1)
	out := make(chan int64)

	// run the incode computer
	go run(mem, in, out)

	// init output builder
	var builder strings.Builder

	// while intcode computer is working
	for {
		// get output
		c, ok := <-out
		if !ok {
			break
		}

		// append output to builder
		builder.WriteRune(rune(c))
	}

	// create view
	view := strings.Split(strings.TrimSpace(builder.String()), "\n")
	w, h := len(view[0]), len(view)

	res := 0

	for i := 1; i+1 < h; i++ {
		for j := 1; j+1 < w; j++ {
			if view[i][j] == '#' && view[i+1][j] == '#' && view[i][j+1] == '#' && view[i-1][j] == '#' && view[i][j-1] == '#' {
				res += i * j
			}
		}
	}

	fmt.Println(fmt.Sprintf("Result, part 1 : %d", res))
}

// getAddr will get address using mod parameter and relative base
func getAddr(mem map[int]int64, offset int, padded string, index int, rb int) int {

	// Get mode for current parameter
	switch padded[3-offset] {
	case '1': // direct
		return index + offset
	case '2': // relative
		return rb + int(mem[index+offset])
	default: // memory
		return int(mem[index+offset])
	}
}

func run(mem map[int]int64, in <-chan int64, out chan<- int64) {

	// index pointer
	ip := 0
	// relative base
	rb := 0

	// translate index jump for each op
	jumps := []int{0, 4, 4, 2, 2, 3, 3, 4, 4, 2}

	for {
		// ensure opcode is padded
		padded := fmt.Sprintf("%05d", mem[ip])
		// convert to int for switch, remove useless 0
		code, _ := strconv.Atoi(padded[3:])

		switch code {
		case 1: // +
			mem[getAddr(mem, 3, padded, ip, rb)] = mem[getAddr(mem, 1, padded, ip, rb)] + mem[getAddr(mem, 2, padded, ip, rb)]
		case 2: // *
			mem[getAddr(mem, 3, padded, ip, rb)] = mem[getAddr(mem, 1, padded, ip, rb)] * mem[getAddr(mem, 2, padded, ip, rb)]
		case 3: // input
			mem[getAddr(mem, 1, padded, ip, rb)] = <-in
		case 4: // output
			out <- mem[getAddr(mem, 1, padded, ip, rb)]
		case 5: // jump-if
			if mem[getAddr(mem, 1, padded, ip, rb)] != 0 {
				ip = int(mem[getAddr(mem, 2, padded, ip, rb)])
				continue
			}
		case 6: // jump-if
			if mem[getAddr(mem, 1, padded, ip, rb)] == 0 {
				ip = int(mem[getAddr(mem, 2, padded, ip, rb)])
				continue
			}
		case 7: // less
			if mem[getAddr(mem, 1, padded, ip, rb)] < mem[getAddr(mem, 2, padded, ip, rb)] {
				mem[getAddr(mem, 3, padded, ip, rb)] = 1
			} else {
				mem[getAddr(mem, 3, padded, ip, rb)] = 0
			}
		case 8: // equal
			if mem[getAddr(mem, 1, padded, ip, rb)] == mem[getAddr(mem, 2, padded, ip, rb)] {
				mem[getAddr(mem, 3, padded, ip, rb)] = 1
			} else {
				mem[getAddr(mem, 3, padded, ip, rb)] = 0
			}
		case 9: // relative base update
			rb += int(mem[getAddr(mem, 1, padded, ip, rb)])
		case 99: // exit
			close(out)
			return
		}

		ip += jumps[code]
	}
}
