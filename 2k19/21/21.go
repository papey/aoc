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
	if len(os.Args) < 3 {
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

	// read springscript passed as argument
	script, err := ioutil.ReadFile(os.Args[2])
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	// exec springscript
	res, output := execute(mem, string(script))
	// if ok
	if res == 0 {
		// print result
		fmt.Println(output)
	} else {
		// print output debug
		fmt.Println(fmt.Sprintf("Result, for script %s : %d", os.Args[2], res))
	}

}

// excute will run the passed springscript
func execute(mem map[int]int64, ss string) (int64, string) {
	// create needed chans
	input := make(chan int64, len(ss))
	output := make(chan int64)
	// init return value
	var draw strings.Builder
	var res int64

	// run intcode computer
	go run(mem, input, output)

	// push springscript into input
	for _, c := range ss {
		input <- int64(c)
	}

	// while it's running
	for {
		ret, ok := <-output
		// check return
		if !ok {
			// if channel is closed, return
			return res, draw.String()
		}
		// if value is over a char character
		if ret >= 128 {
			// save return value
			res = ret
		} else {
			// write rune, to get debug log
			draw.WriteRune(rune(ret))
		}
	}

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
